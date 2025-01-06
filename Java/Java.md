# Java 基础

## 面向对象

> 面向对象的三大特性：
>
> - 封装
> - 继承
> - 多态

### 三大特性

#### 封装

封装是将数据与对数据操作的方法进行绑定，形成一个独立的操作单元（类），通过封装，对象的内部状态（属性）被隐藏起来，只能通过类提供的方法进行访问和修改

#### 继承

继承是一种机制，允许一个类（子类或者派生类）继承另一个类的属性和方法，子类可以重用父类的方法、并添加或者重写自己的属性和方法。

继承的好处包括代码重用、扩展性和可维护性

继承实现了 **IS-A** 关系，继承应该遵循里氏替换原则，子类对象必须能够替换掉所有父类对象。

> 里氏替换原则（Liskov Substitution Principle，LSP）
>
> 如果对每一个类型为S的对象o1，都有类型为T的对象o2，使得以T定义的所有程序P在所有的对象o1都代换成o2时，程序P的行为没有发生变化，那么类型S是类型T的子类型

#### 多态

多态允许对象通过统一的接口表现出不同的行为。

> 多态分为编译时多态和运行时多态:
>
> - 编译时多态主要指方法的重载
> - 运行时多态指是在程序运行时才能确定

在运行时多态中，子类对象可以替换父类对象，并且当调用父类方法时，实际执行的是子类重写的方法。这种机制使得代码更加灵活和可扩展。

多态的好处包括灵活性、可扩展性和接口一致性。它允许开发者在不修改现有代码的情况下添加新的功能。



## 知识点

### 数据类型

#### 基本数据类型与包装类

八个基本数据类型。基本类型都有对应的包装类型，基本类型与其对应的包装类型之间的赋值使用自动装箱与拆箱完成。

- byte/1
- char/2
- short/2
- int/4
- long/8
- float/4
- double/8
- boolean

#### 缓存池

new Integer(10)和 valueOf(10)

- new Integer(10)每次都会生成一个新的对象
- 而valueOf(10)会尝试从缓存池中获取，获取不到则生成一个新的Integer对象

```java
public class Demo {
    public static void main(String[] args) {
        Integer a = new Integer(10);
        Integer b = new Integer(10);
        // false
        System.out.println(a == b);

        Integer c = Integer.valueOf(10);
        Integer d = Integer.valueOf(10);
        // true
        System.out.println(c == d);

        Integer e = Integer.valueOf(129);
        Integer f = Integer.valueOf(129);
        // false
        System.out.println(e == f);
    }
}

```



缓存池有大小，以下code copy自源码，可以发现，除非通过参数手动设置，否则缓存池上限为127，下限为-128

```java
public static Integer valueOf(int i) {
    if (i >= IntegerCache.low && i <= IntegerCache.high)
        return IntegerCache.cache[i + (-IntegerCache.low)];
    return new Integer(i);
}

private static class IntegerCache {
        static final int low = -128;
    	static final int high;
        static final Integer cache[];
    
     	static {
            // high value may be configured by property
            int h = 127;
            String integerCacheHighPropValue = sun.misc.VM.getSavedProperty("java.lang.Integer.IntegerCache.high");
            if (integerCacheHighPropValue != null) {
                try {
                    int i = parseInt(integerCacheHighPropValue);
                    i = Math.max(i, 127);
                    // Maximum array size is Integer.MAX_VALUE
                    h = Math.min(i, Integer.MAX_VALUE - (-low) -1);
                } catch( NumberFormatException nfe) {
                    // If the property cannot be parsed into an int, ignore it.
                }
            }
            high = h;
     	}
}


```



其他数据类型也类似，数据范围都是-128~127，但浮点数没有缓存池

- Byte

  - byte是全范围，但是也是-128~127

    ```java
    private static class ByteCache {
            private ByteCache(){}
    
            static final Byte cache[] = new Byte[-(-128) + 127 + 1];
    
            static {
                for(int i = 0; i < cache.length; i++)
                    cache[i] = new Byte((byte)(i - 128));
            }
        }
    ```

    

- Character

  ```java
  private static class CharacterCache {
      private CharacterCache(){}
  
      static final Character cache[] = new Character[127 + 1];
  
      static {
          for (int i = 0; i < cache.length; i++)
              cache[i] = new Character((char)i);
      }
  }
  ```

  

- Long

  ```java
  private static class LongCache {
          private LongCache(){}
  
          static final Long cache[] = new Long[-(-128) + 127 + 1];
  
          static {
              for(int i = 0; i < cache.length; i++)
                  cache[i] = new Long(i - 128);
          }
  }
  ```

  

- Short

  - ```java
    private static class ShortCache {
            private ShortCache(){}
    
            static final Short cache[] = new Short[-(-128) + 127 + 1];
    
            static {
                for(int i = 0; i < cache.length; i++)
                    cache[i] = new Short((short)(i - 128));
            }
        }
    ```



#### String

##### String.intern()

> String.intern严格来说禁止在生产环境使用，但是还是要看各家的技术规范和使用场景

intern是一个native方法，调用 intern 方法时，如果字符串常量池中已包含等于该方法确定equals(Object)的字符串，则返回池中的字符串。否则，此String对象将添加到池中，并返回对此String对象的引用

如果是采用 "" 这种使用双引号的形式创建字符串实例，会自动地将新建的对象放入 String Pool 中。

```Java
String s = "nanchaos"
```

