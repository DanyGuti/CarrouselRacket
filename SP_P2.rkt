#lang racket
; Made by Daniel Gutiérrez Gómez A01068056
(define inventory-med-2(list
     (list "A"  ;Nombre Precio Indice Cantidad
                   (list "A1" 100 1 15)
                   (list "A2" 200 2 25)
                   (list "A3" 300 3 25)
                   (list "A4" 400 4 23)
                   (list "A5" 500 5 1))
     (list "B"
                    (list "B1" 100 1 30)
                    (list "B2" 200 2 80)
                    (list "B3" 300 3 19)
                    (list "B4" 400 4 31)
                    (list "B5" 500 5 12))
     (list  "C"
                    (list "C1" 100 1 12)
                    (list "C2" 200 2 5)
                    (list "C3" 300 3 7)
                    (list "C4" 400 4 11)
                    (list "C5" 500 5 24))
     (list  "D"
                    (list "D1" 100 1 23)
                    (list "D2" 200 2 18)
                    (list "D3" 300 3 37)
                    (list "D4" 400 4 55)
                    (list "D5" 500 5 90))
     (list  "E"
                    (list "E1" 100 1 12)
                    (list "E2" 200 2 11)
                    (list "E3" 300 3 10)
                    (list "E4" 400 4 9)
                    (list "E5" 500 5 8))
                    ))

(define left-regex #rx"^[A-Z]1$") ; Out of bounds to the left when match
(define right-regex #rx"^[A-Z]5$") ; Out of bounds to the right when match
(define total-regex #rx"^(A|B|C|D|E)$") ; Total regex to search for row

; Generate rows of letters: ("A", "B", "C", "D", "E")
(define generate-row
  (lambda (inventory)
    (map car inventory)))

; Generate the rows associated to a certain letter
(define generate-rows
  (lambda (inventory letter)
    (let ((rows (assoc letter inventory)))
      (if rows
          (cdr rows)
          '()))))

; Move the carrusel down, if E and down, return to A
(define move-carrousel-down
  (lambda (inventory letter)
    (let ((rows (assoc letter inventory)))
      (cond ((and (not (equal? letter "F"))rows)(cdr rows))
            ((equal? letter "F")(cdr (assoc "A" inventory)))
          (else ('()))))))

; Move the carrusel up, if A and up, return to E
(define move-carrousel-up
  (lambda (inventory letter)
    (let ((rows (assoc letter inventory)))
      (cond ((and (not (equal? letter "@")) rows) (cdr rows))
            ((equal? letter "@")(cdr(assoc "E" inventory)))
          (else ('()))))))

; Matches a row and a col based on a letter and index
(define match-row-col
  (lambda (row-match index)
    (car(filter (lambda (row) (equal? index(caddr row))) row-match))))

; Matches a row and a col based on a product 
(define match-row-col-product
  (lambda (row-match string)
    (car(filter (lambda (row) (equal? (substring string 0 2) (car row))) row-match))))

; Increase or decrease ASCII char based on passed char
(define (move-char c symbol)
  (integer->char (symbol (char->integer c) 1)))

; Generate the right col
(define get-col-right
  (lambda (inventory)
    (map last (map cdr inventory))))

; Generate the left col
(define get-col-left
  (lambda (inventory)
    (map (lambda (sublist) (last sublist))inventory)))

; Minimum recursive calls
(define min-recursive-steps
  (lambda (list)(assoc(apply min (map car list))list)))

; Check for substrings
; -1 substr(0, 1)
; 0 substr(1, 2)
; 1 substr(0, 2)
(define get-letter-index-window
    (lambda (window flag)
     (cond  ((equal? flag -1) (substring (car window) 0 1))
            ((equal? flag 0)(substring(car window) 1 2))
            ((equal? flag 1)(substring(car window) 0 2)))))

; Check for substrings
; -1 substr(0, 1)
; 1 substr(0, 2)
(define get-product-letter-index
    (lambda (product flag)
     (cond ((equal? flag -1) (substring product 0 1))((equal? flag 1) (substring product 0 2)))))

; Generate letter when rows and window passed
(define get-letter-match
    (lambda (row window)
      (car(filter(lambda (rows) (equal? rows (substring (car window) 0 1)))row))))

; Move to the left or right based on passed flag
; 0 go to the left
; 1 go to the right
(define (move-left-right inventory window flag)
  (cond ((null? inventory) window) ; Look for row where window belongs 
        ((equal? flag 0)(look-inventory (get-letter-match (generate-row inventory) window)(- (caddr window) 1)(generate-rows inventory (get-letter-match (generate-row inventory) window))))
        ((equal? flag 1)(look-inventory (get-letter-match (generate-row inventory) window)(+ (caddr window) 1)(generate-rows inventory (get-letter-match (generate-row inventory) window))))
        (else (move-left-right (cdr inventory) window flag))))

; Move up or down based on passed symbol
; - go up
; + go down
(define (move-up-down inventory window symbol)
    (cond ((null? inventory) window)
    ((and(equal? (substring (get-letter-match (generate-row inventory) window) 0 1) "A") (equal? symbol -))
    (match-row-col (generate-rows inventory "E") (caddr window)))
    ((and(equal? (substring (get-letter-match (generate-row inventory) window) 0 1) "E") (equal? symbol +))
    (match-row-col (generate-rows inventory "A") (caddr window)))
    (else(match-row-col (generate-rows inventory (string(move-char (string-ref(get-letter-match (generate-row inventory) window) 0) symbol)))(caddr window)))))

; Look for same indexes in inventary
; Return window at position
(define (look-inventory row index inventory)
  (cond ((null? inventory) null)
        ((equal?(caddar inventory) index) ; Look for same indexes and rows return the last window
         (car inventory))
        (else (look-inventory row index (cdr inventory)))))

; Min steps to get to a product
; First go up, then down.
; For each of those go left and right till out of bounds
; If out of bounds, just return the other list with the counter
(define (min-steps-to-product rows product quantity inventory window)
  (cond ((null? product) null)
        ((equal? (car rows) (get-product-letter-index product -1)) ; Identify the row where the product is
         (let ((min-up (min-to-row-up(get-letter-match (generate-row inventory) window) inventory (generate-rows inventory (get-letter-match (generate-row inventory) window)) window product))
               (min-down (min-to-row-down (get-letter-match (generate-row inventory) window) inventory (generate-rows inventory (get-letter-match (generate-row inventory) window)) window product)))
           (cond ((null? (cdr min-up))(min-down))
                 ((null? (cdr min-down))(min-up))
                 (else (retire-product product quantity (list min-up min-down))))))
        (else (min-steps-to-product (cdr rows) product quantity inventory window))))

; Retire product with the min possible steps to get
; there from a starting position
(define (retire-product product quantity list-steps-window)
  (cond ((null? product)
        (let ((result (- (caddr product) quantity)))
            (cond ((< result 0) 0)
                (else (result)))))
        (else (let ((result (- (cadr(cddadr (min-recursive-steps list-steps-window))) quantity)))
          (cond (( < result 0) 0)
                (else (display
                       (string-append "Queda: " (number->string result) " del producto: " product " con los siguientes pasos: "
                                    (number->string (car(min-recursive-steps list-steps-window))) " " ))
                     (newline)))))))


; Receive inventory and window
; Calls move-up-down with - to move one cell up
(define (U inventory window)
  (cond ((null? inventory) null)
        (else (move-up-down inventory window -))))

; Receive inventory and window
; Calls move-up-down with + to move one cell down
(define (D inventory window)
  (cond ((null? inventory) null)
        (else (move-up-down inventory window +))))

; Receive inventory and window
; Calls move-left-right if not out of bounds with 0 to move left
(define (L inventory window)
  (cond ((null? inventory) null)
        ((has-match-left (get-col-left inventory) window) null)
        (else(move-left-right inventory window 0))))

; Receive inventory and window
; Calls move-left-right if not out of bounds with 1 to move right
(define (R inventory window)
  (cond ((null? inventory) null)
        ((has-match-right (get-col-right inventory) window) null)
        (else(move-left-right inventory window 1))))

; Compare left col with window and regex
(define (has-match-left left-col window)
  (cond ((null? left-col)#f)
        ((regexp-match? left-regex (car window))#t)
        (else (has-match-left (cdr left-col) window))))

; Compare right col with window and regex
(define (has-match-right right-col window)
  (cond ((null? right-col)#f)
        ((regexp-match? right-regex (car window))#t)
        (else (has-match-right (cdr right-col) window))))

; Evaluate till the product is found to the right
; Return the steps to get there
(define (min-check-cols-right inventory window product)
      (cond ((null? window)(list 0 window))
          ((equal? (get-letter-index-window window 1) (get-product-letter-index product 1)) (list 0 window))
    (else (let((result (min-check-cols-right inventory (R inventory window) product)))
          (cons(+ 1 (car result)) (cdr result))))))

; Evaluate till the product is found to the right
; Return the steps to get there
(define (min-check-cols-left inventory window product)
    (cond ((null? window)(list 0 window))
      ((equal? (get-letter-index-window window 1) (get-product-letter-index product 1)) (list 0 window))
    (else (let((result (min-check-cols-left inventory (L inventory window) product)))     
         (cons(+ 1 (car result)) (cdr result))))))

; Evaluate till the product is found to the right
; Return the steps to get there
; returns left or right steps based on the results
(define (min-check-cols inventory window product)
  (cond ((equal? (get-letter-index-window window 1) (get-product-letter-index product 1)) (list 0 window))
        ((equal? (get-letter-index-window window 0) "1")
         (let ((result-right(min-check-cols-right inventory (R inventory window) product)))
           (cons (+ 1 (car result-right)) (cdr result-right))))
        
        ((equal? (get-letter-index-window window 0) "5")
         (let ((result-left(min-check-cols-left inventory (L inventory window) product)))
           (cons (+ 1 (car result-left)) (cdr result-left))))
        (else
         (let((result-right (min-check-cols-right inventory (R inventory window) product))
              (result-left (min-check-cols-left inventory (L inventory window) product)))
           (cond ((null? (cdr result-right)) (cons(+ 1 (car result-left)) (cdr result-left)))
                  (else (cons (+ 1 (car result-right)) (cdr result-right))))))))

; Evaluate till the row is found upwards
; return the sum of the steps and the state at the window
(define (min-to-row-up letter inventory row-belonged window product)
  (cond ((equal? (get-letter-index-window window -1) (get-product-letter-index product -1))(min-check-cols inventory window product))
  (else (let((result (min-to-row-up letter inventory row-belonged (U inventory window) product)))
          (cons(+ 1 (car result)) (cdr result))))))

; Evaluate till the row is found upwards
; return the sum of the steps and the state at the window
(define (min-to-row-down letter inventory row-belonged window product)
  (cond ((equal? (get-letter-index-window window -1) (get-product-letter-index product -1))(min-check-cols inventory window product))
  (else (let((result (min-to-row-down letter inventory row-belonged (D inventory window) product)))
          (cons(+ 1 (car result)) (cdr result))))))

(min-steps-to-product (generate-row inventory-med-2) "C2" 2 inventory-med-2 (list "A1" 100 1))
(min-steps-to-product (generate-row inventory-med-2) "D3" 3 inventory-med-2 (list "A3" 300 3))
(min-steps-to-product (generate-row inventory-med-2) "E5" 1 inventory-med-2 (list "A1" 100 1))
(min-steps-to-product (generate-row inventory-med-2) "B4" 10 inventory-med-2 (list "D2" 200 2))