#### 双列表队列的实时版本

传统的双列表"马蹄形"队列是这样的

```
struct Queue[T] {
  front:List[T]
  rear:List[T]
}
```

只有在front耗尽的情况下，才会触发平衡调整

后续改进是记录front和rear的长度，发现rear长度超过front就立刻进行平衡调整，具体操作是

```
front ++ reverse(rear)
```

但是平衡调整在改进版中仍然是一次性完成的耗时长操作，实时版选择在定义中增加一个状态机，并将平衡调整改写为使用状态机完成，每次pop/push时都会执行一步状态转移。

不过，它的平衡调整分为两个阶段：Reverse与Concat.

+ Reverse阶段同时创建front和rear的逆序版本accf与accr

+ Concat阶段每一次状态转移都将accf的顶部元素放到accr上


为了使pop可以正常使用，外部保留了原本的front，同时状态机内部设置了一个计数器，外部pop一次则减一，内部在Reverse阶段往accf里放一个元素加一，在Concat阶段往accr上放一个元素则减一，这可以看作内外从头尾两端去消费front，通过计数器控制concat过程。尽管如此，仍然存在场景需要从accr上面丢弃掉一个元素来避免重复消费。

