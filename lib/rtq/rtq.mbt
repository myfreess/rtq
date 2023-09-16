pub enum State[T] {
  Empty
  Reverse(Int, List[T], List[T], List[T], List[T]) // front_length, acc front, front, acc rear, rear
  Concat(Int, List[T], List[T]) // front_length, acc, front
  Done(List[T])
}

pub struct RTQ[T] {
  front:List[T]
  front_length:Int
  state:State[T]
  rear:List[T]
  rear_length:Int
}

// pub func to_string[T:Show](self:RTQ[T])

func abort[T](self:State[T]) -> State[T] {
  // 计数器减一
  // 此方法只被pop调用
  // 故在反转阶段计数器一定大于0
  // 在连接阶段也大于等于0
  // 可以把它看作某种"资源"
  // 出队操作和单步的连接操作都会消耗它
  // 如果在连接阶段abort被调用而计数器为零
  // 意味着发生了资源竞争
  // 此时只能让连接操作回退一步，丢弃一个元素
  match self {
    Concat(0, Cons(_, acc), _) => Done(acc) 
    Concat(n, acc, front) => Concat(n - 1, acc, front)
    Reverse(n, accf, front, accr, rear) => Reverse(n - 1, accf, front, accr, rear)
    s => s
  }
}

func next[T](self:State[T]) -> State[T] {
  match self {
    Reverse(n, accf, Cons(x, front), accr, Cons(y, rear)) => Reverse(n+1, Cons(x, accf), front, Cons(y, accr), rear)
    Reverse(n, accf, Nil, accr, Cons(y, Nil)) => next(Concat(n, Cons(y, accr), accf))
    Concat(0, acc, _) => Done(acc)
    Concat(n, acc, Cons(x, front)) => Concat(n-1, Cons(x, acc), front)
    s => s
  }
}

func step[T](front:List[T], n:Int, state:State[T], rear:List[T], m:Int) -> RTQ[T] {
  // 状态机执行一步
  fn queue(s:State[T]) -> RTQ[T] {
    match s {
      Done(f) => {front:f, front_length:n, state:Empty, rear:rear, rear_length:m}
      s       => {front:front, front_length:n, state:s, rear:rear, rear_length:m}
    }
  }

  queue(state.next())
}

func balance[T](front:List[T], n:Int, state:State[T], rear:List[T], m:Int) -> RTQ[T]{
  if(m <= n){
    step(front, n, state, rear, m)
  } else {
    step(front, m + n, next(Reverse(0, Nil, front, Nil, rear)), Nil, 0)
  }
}

pub func push[T](self:RTQ[T], x:T) -> RTQ[T] {
  match self {
    {front:f, front_length:n, state:s, rear:r, rear_length:m} => balance(f,n,s,Cons(x, r),m+1)
  }
}

pub func pop[T](self:RTQ[T]) -> Option[RTQ[T]]{
  match self {
    {front:Cons(_, f), front_length:n, state:s, rear:r, rear_length:m} => Some(balance(f, n - 1, s.abort(), r, m))
    _ => None
  }
}

pub func peek[T](self:RTQ[T]) -> Option[T] {
  match self.front {
    Nil => None 
    // 前置条件保证只要不是没push元素,front一定不为Nil
    Cons(x, _) => Some(x)
  }
}

// 从示例复制的
func length[T](self: List[T]) -> Int {
  match self {
    Nil => 0
    Cons(_, xs) => 1 + xs.length()
  }
}

pub func from_list[T](f:List[T]) -> RTQ[T] {
  {front:f, front_length:f.length(), state:Empty, rear:Nil, rear_length:0}
}