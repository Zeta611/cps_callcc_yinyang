# CPS, call/cc, and yin-yang

```scheme
DS:     (Let yin
 (App (Abs cc (Seq (Show (Str @)) (Var cc)))
  (App (Var call/cc) (Abs c (Var c))))
 (Let yang
  (App (Abs cc (Seq (Show (Str *)) (Var cc)))
   (App (Var call/cc) (Abs c (Var c))))
  (App (Var yin) (Var yang))))
CPS: (Abs k#51
 (App
  (Abs k#29
   (App (Var k#29)
    (Abs yin
     (Abs k#28
      (App
       (Abs k#6
        (App (Var k#6)
         (Abs yang
          (Abs k#5
           (App (Abs k#1 (App (Var k#1) (Var yin)))
            (Abs f#3
             (App (Abs k#2 (App (Var k#2) (Var yang)))
              (Abs v#4 (App (App (Var f#3) (Var v#4)) (Var k#5))))))))))
       (Abs f#26
        (App
         (Abs k#25
          (App
           (Abs k#16
            (App (Var k#16)
             (Abs cc
              (Abs k#15
               (App
                (Abs k#9
                 (App (Var k#9) (Abs f#7 (Abs k#8 (App (Var k#8) (Var cc))))))
                (Abs f#13
                 (App
                  (Abs k#12
                   (App (Abs k#10 (App (Var k#10) (Str *)))
                    (Abs v#11 (App (Var k#12) (Show (Var v#11))))))
                  (Abs v#14 (App (App (Var f#13) (Var v#14)) (Var k#15))))))))))
           (Abs f#23
            (App
             (Abs k#22
              (App (Abs k#17 (App (Var k#17) (Var call/cc)))
               (Abs f#20
                (App
                 (Abs k#19
                  (App (Var k#19)
                   (Abs c (Abs k#18 (App (Var k#18) (Var c))))))
                 (Abs v#21 (App (App (Var f#20) (Var v#21)) (Var k#22)))))))
             (Abs v#24 (App (App (Var f#23) (Var v#24)) (Var k#25)))))))
         (Abs v#27 (App (App (Var f#26) (Var v#27)) (Var k#28))))))))))
  (Abs f#49
   (App
    (Abs k#48
     (App
      (Abs k#39
       (App (Var k#39)
        (Abs cc
         (Abs k#38
          (App
           (Abs k#32
            (App (Var k#32) (Abs f#30 (Abs k#31 (App (Var k#31) (Var cc))))))
           (Abs f#36
            (App
             (Abs k#35
              (App (Abs k#33 (App (Var k#33) (Str @)))
               (Abs v#34 (App (Var k#35) (Show (Var v#34))))))
             (Abs v#37 (App (App (Var f#36) (Var v#37)) (Var k#38))))))))))
      (Abs f#46
       (App
        (Abs k#45
         (App (Abs k#40 (App (Var k#40) (Var call/cc)))
          (Abs f#43
           (App
            (Abs k#42
             (App (Var k#42) (Abs c (Abs k#41 (App (Var k#41) (Var c))))))
            (Abs v#44 (App (App (Var f#43) (Var v#44)) (Var k#45)))))))
        (Abs v#47 (App (App (Var f#46) (Var v#47)) (Var k#48)))))))
    (Abs v#50 (App (App (Var f#49) (Var v#50)) (Var k#51)))))))
@*@**@***@****@*****@******@*******@********@*********@**********@***********@************@*********...
```
