func unwrap[T](self:Option[T]) -> T {
  match self {
    None => abort("found None")
    Some(v) => v
  }
}


func init {
  let q = @rtq.from_list(Nil)
  let q1 = q.push(1).push(4).push(0).push(7).pop().unwrap().pop().unwrap()
  
  match q1.peek() {
    None => println("wrong")
    Some(x) => println("\(x)") 
  }
}
