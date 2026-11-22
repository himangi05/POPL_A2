#lang racket/base

; inorder-list: returns the list of the values of a binary tree in inorder
; (left subtree, node, right subtree).
; Arguments: tree, either () or (value left right).
; The list is built without append or reverse: the walk visits the right subtree first,
; consing each value onto an accumulator, so the left-to-right order comes out directly.
; Reads: inorder(tree, acc) = inorder(left, (value . inorder(right, acc))), and inorder((), acc) = acc.
(define (inorder-list tree)
  (let walk ((t tree) (acc '()))
    (if (null? t)
        acc
        (walk (cadr t)
              (cons (car t)
                    (walk (caddr t) acc))))))