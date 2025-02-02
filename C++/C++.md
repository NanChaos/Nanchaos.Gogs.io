## 基本

### 数据类型

- bool
- char
- int
  - short int
  - long int
  - signed int 有符号
  - unsigned int 无符号
  - const 常量
  - volatile
  - mutable
- float
- double
- void
- wchar_t





```c++
# 自动类型推断
auto x = 10;

# 获取表达式的类型
decltype(x) y = 20;

# 空指针常量
int* ptr = nullptr;
```



```c++
//
// Created by nanchaos on 2025/2/2.
//

#include <iostream>
#include <ctime>
using namespace std;

int main() {
  // 中文windows下有乱码 windows默认的是GBK编码
  system("chcp 65001");
  int var = 20;
  int *ip = &var;

  cout << ip << endl;

  // 基于当前系统的当前日期/时间
  time_t now = time(0);

  // 把 now 转换为字符串形式
  char* dt = ctime(&now);

  cout << "中文时间" << dt << endl;
}
```