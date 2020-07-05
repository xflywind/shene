discard """
output: '''
a.cid + b + c = 40
12
13
a.cid + b + c = 113
Dog
OK
12
'''
"""


import strformat
import ../src/shene


type
  Animal*[T] = object of RootObj
    id: int
    sleepImpl: proc (a: T) {.nimcall, gcsafe.}
    barkImpl: proc (a: T, b: int, c: int): string {.nimcall, gcsafe.}
    danceImpl: proc (a: T, b: string): string {.nimcall, gcsafe.}

  Cat* = object of Animal[Cat]
    cid: int

  People*[T] = object
    pet: Must[Animal[T], T]


proc sleep*(a: Cat) =
  discard

proc bark*(a: Cat, b: int, c: int): string =
  result = fmt"{a.cid + b + c = }"

proc dance*(a: Cat, b: string): string =
  result = fmt"{a.id = } |-| {b = }"

proc newCat*(id, cid: int): Must[Animal[Cat], Cat] =
  result.id = id
  result.cid = cid
  result.sleepImpl = sleep
  result.barkImpl = bark
  result.danceImpl = dance


let p = People[Cat](pet: newCat(id = 12, 13))
echo p.pet.call(barkImpl, 13, 14)
p.pet.call(sleepImpl)
echo p.pet.id
echo p.pet.cid

let m = newCat(13, 14)
echo m.call(barkImpl, 12, 87)
# discard p.pet.barkImpl
# echo p.pet.mget(barkImpl)

type
  Dog = object
    name: string


proc bark(d: Dog, b: int, c: int): string =
  echo "Dog"
  echo d.name

proc newDog(): Must[Animal[Dog], Dog] =
  result.name = "OK"
  result.id = 12
  result.barkImpl = bark


let d = newDog()
let p1 = People[Dog](pet: d)
discard p1.pet.call(barkImpl, 13, 14)

doAssertRaises(ImplError):
  p1.pet.call(sleepImpl)
echo p1.pet.id
