// RUN: %target-typecheck-verify-swift

protocol P1 : AnyObject { }

protocol P2 : AnyObject, class { } // expected-error{{redundant 'class' requirement}}{{20-27=}}

protocol P3 : P2, class { } // expected-error{{'class' must come first in the requirement list}}{{15-15=class, }}{{17-24=}}
// expected-warning@-1 {{redundant constraint 'Self' : 'AnyObject'}}
// expected-note@-2 {{constraint 'Self' : 'AnyObject' implied here}}

struct X : AnyObject { } // expected-error{{'class' constraint can only appear on protocol declarations}}
