# 默认代码规范

以下是本库默认的代码风格，适用于新增或实际修改的手写业务代码，不绑定具体芯片或应用。不得为补齐这些格式而擅自批改未涉及文件、生成区或第三方库。当前工程有更具体约定时先核对。

## 标识符与接口

| 对象 | 形式 | 示例 |
|---|---|---|
| 变量、参数、结构体成员 | 首段小写，其余每个单词首字母大写，以 `_` 分隔 | `sample_Frame_Ready`、`sample_Period_Ms` |
| 业务函数，含 static 函数 | 每段首字母大写，以 `_` 分隔 | `Sample_Get_Frame()`、`Buffer_Get_Count()` |
| 宏与枚举常量 | 全大写下划线，必要时有模块前缀 | `SAMPLE_CHANNEL_COUNT`、`APP_RUNNING` |

- 各单词均分隔，不能写成 `sampleFrameReady`、`sample_frame_ready` 或 `sample_FrameReady`。
- 命名表达实际含义；明确单位时写入名字，名称与数值换算一致。缩写遵循同一格式，如 `sample_Adc_Value`、`Sample_Adc_Start()`。
- 固定宽度整数用于硬件/协议相关数据；私有状态和内部函数用 `static`，公共声明放模块头文件，不任意导出可写全局变量。
- 函数无参数写 `(void)`；头文件使用保护宏。结构体/类型命名沿用当前工程，不凭空新增用户未规定的类型命名体系。
- `main`、`SystemClock_Config`、`MX_*_Init`、`hadc1`、`htim1`、HAL 回调、IRQ 和库字段等保持规定名字；不为匹配业务风格重命名。

## 条件与排版

- 禁止在新增/修改的业务实现及宏中使用三元条件运算符 `?:`，赋值、返回值和实参中的选择均展开为清楚的 `if/else`。
- 条件和循环体写完整花括号；条件分支即使只有一条语句也不省略。状态分发可用清晰的 `switch`。
- `&&`、`||` 可组合条件，但不得以短路副作用替代应执行的业务分支。
- 4 个空格缩进；函数与控制语句的左花括号独占一行。运算符两侧、逗号后留空格。
- include、宏、变量、标志、函数声明、函数实现等区域之间至少一行空白；局部变量声明与执行语句、不同处理阶段之间至少一行空白。
- 相邻函数之间恰好两条完全空白的行；若有函数说明注释，注释紧随其说明的函数之前，不把注释与函数拆开。
- 空白行不含空格或制表符。不要为风格移动 USER CODE 标记或格式化生成区。

## 逐项中文注释与标志分组

- 每个新增/修改的业务变量声明或定义、宏定义必须逐项有中文作用说明。覆盖模块/全局/局部变量、常量对象、数组、指针、结构体成员、函数参数及头文件保护宏。
- 一条声明只定义一个变量。普通声明和宏用行尾 `// 中文说明`；参数可换行逐项用 `/* 中文说明 */`，保持合法语法。多行宏不破坏续行，必要时改成函数。
- 写清作用，按需要补充单位、范围、顺序、指向对象；标志注明实际取值，如 `0=无效，1=有效`。不以“变量”“临时值”“标志位”等空泛描述代替。
- 组上方注释不能替代逐项注释；后续普通赋值无需机械重复声明说明。算法注释解释非显然计算、硬件边界和状态转换原因。
- 同一作用域先集中定义普通数值、计数、时间、数组，再空一行用中文分组注释引出标志变量。模块、局部与结构体成员均适用；只有一类不设空组。
- 按语义判定标志：就绪、使能、有效、完成、请求属于标志；`uint8_t` 索引或百分比仍是普通变量。参数按接口语义排序，不强行分组改签名。
- 中断共享数据按所有权与同步方案处理；`volatile` 不能替代临界区、原子操作或一致性快照。

## 合规风格示例

以下仅演示采样模块的命名、注释和空行，不指定真实周期或硬件参数。示例中的成对用户区仅演示组织方式，独立手写工程不要求额外创建这些标记。

```c
/* USER CODE BEGIN Includes */
#include <stdint.h>
/* USER CODE END Includes */

/* USER CODE BEGIN Defines */
#define SAMPLE_FRAME_INVALID 0U // 采样帧处于无效状态
/* USER CODE END Defines */

/* USER CODE BEGIN Variables */
// 普通变量
static uint32_t sample_Frame_Seq; // 最近一次发布的采样帧序号

// 标志变量
static uint8_t sample_Frame_Valid; // 采样帧有效标志：0=无效，1=有效
/* USER CODE END Variables */

/* USER CODE BEGIN Functions */
void Sample_Init(void)
{
    sample_Frame_Seq = 0U;
    sample_Frame_Valid = SAMPLE_FRAME_INVALID;
}


void Sample_Publish(
    uint8_t frame_Valid) /* 待发布采样帧的有效状态：0=无效，1=有效 */
{
    if (frame_Valid == SAMPLE_FRAME_INVALID)
    {
        sample_Frame_Valid = SAMPLE_FRAME_INVALID;
        return;
    }

    sample_Frame_Seq++;
    sample_Frame_Valid = 1U;
}
/* USER CODE END Functions */
```

实际工程还须在对应头文件声明公共接口并登记构建；头文件由生成器管理时遵守其扩展边界。该示例没有定义跨中断同步方案，不得直接当作 DMA/ISR 的帧发布实现。
