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


; print-inorder: prints the inorder list of the tree's values on one line, then a newline.
; Arguments: tree, either () or (value left right). Prints with display; for () it prints ().
(define (print-inorder tree)
  (display (inorder-list tree))
  (newline))

  
; preorder-list: returns the list of the values of a binary tree in preorder
; (node, left subtree, right subtree).
; Arguments: tree, either () or (value left right).
; Same accumulator idea as inorder-list, so no append or reverse is needed.
; Reads: preorder(tree, acc) = (value . preorder(left, preorder(right, acc))), and preorder((), acc) = acc.
(define (preorder-list tree)
  (let walk ((t tree) (acc '()))
    (if (null? t)
        acc
        (cons (car t)
              (walk (cadr t)
                    (walk (caddr t) acc))))))

                    
; postorder-list: returns the list of the values of a binary tree in postorder
; (left subtree, right subtree, node).
; Arguments: tree, either () or (value left right).
; Same accumulator idea as inorder-list, so no append or reverse is needed.
; Reads: postorder(tree, acc) = postorder(left, postorder(right, (value . acc))), and postorder((), acc) = acc.
(define (postorder-list tree)
  (let walk ((t tree) (acc '()))
    (if (null? t)
        acc
        (walk (cadr t)
              (walk (caddr t)
                    (cons (car t) acc))))))