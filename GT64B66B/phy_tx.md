# 详解Phy_tx

![image](https://github.com/Vikkdsun/GT_64B_66B/assets/114153159/6fa8884b-17ab-4256-af8e-ef3b5976ff25)

## GT_PORT

这个端口的信号：

o_gt0_txdata： 发送给GT的信号，根据64B66B格式组包，需要注意的是，当o_gt0_txsequence这个信号为32和0时，o_gt0_txdata需要自保持

![f684a30c9a6b469e0ce19d59952bc2b](https://github.com/Vikkdsun/GT_64B_66B/assets/114153159/a97f22c4-3e7f-4638-81fb-4e41a5d5df55)

o_gt0_txheader： 指示当前数据是纯数据（01）还是混合数据（10）

o_gt0_txsequence： 外部计数器，0-31正确传入数据，但是32时GT不工作，所以需要数据保持一下

## 内部逻辑

### o_gt0_txsequence

对这个信号的控制0-32-0-32这样循环，为什么记到32，因为GT 0-31工作，还需要一个周期表示不工作

### o_gt0_txdata

#### 组包FIFO

把输入的数据先放到FIFO以便后续组包。

具体内容讲起来非常麻烦，结合仿真容易理解，这里提几个点：

1. rden_begin：决定rd_run

2. rd_run：拉高表示在读状态，通过sequence判断拉不拉高rden

3. sequence： 根据sequence 32和0 的outdata值相同可以知道，用来组成outdata的fifo_out需要在31和32时相同，这就意味着rden在30时可以拉高，31时要拉低。也就是如果在rd_run拉高时同时有sequence为30，就要拉低rden(因为寄存器赋值打一拍)

4. rd_run拉低的条件：因为fifo_out比rden慢一拍，所以如果根据rden做一个计数器的加法操作，那么rden得多记一拍来覆盖所有读出来的数据，所以不在cnt = len-1时拉低，而是在len时拉低，同时也不需要加一个rden为高的条件了，因为cnt=len时，一定是全部都都出来了。

5. 根据上一个条件我们知道，cnt = 1-len时是fifo_out是真实数据的时候，用这个数据输出outdata，如果outdata和输入的data长度相同这就可以了；但是如果不同，也就是还需要再多一个周期，但是计数器只有1-len，后面就是0了，所以计数器也打一拍，用打一拍后的计数器为len时做多出来的数据

6. 当计数器当前的值等于上一个周期的值，就把outdata赋值给outdata

7. 这些点不清晰的地方看一下仿真图就清晰了，注意！不要把第一个rden和后面的rden分开看，他们都是在rd_run情况下判断rden是否拉高，一样的。








