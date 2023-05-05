#lang racket

;; Made by Daniel Gutiérrez Gómez A01068056
(define left-regex #rx"^[A-Z]1$") ; Out of bounds to the left when match
(define right-regex #rx"^[A-Z]5$") ; Out of bounds to the right when match

;; Generate rows of letters: ("A", "B", "C", "D", "E", "F", "G")
(define generate-row
  (lambda (inventory)
    (map car inventory)))

;; Generate the rows associated to a certain letter
(define generate-rows
  (lambda (inventory letter)
    (let ((rows (assoc letter inventory)))
      (if rows
          (cdr rows)
          '()))))
;; Generate the value of the inventory
(define suma-inventario-precio
  (lambda (lst)
    (apply + (map (lambda (sublst) (*(string->number(cadr sublst))(string->number (cadddr sublst)))) lst))))

;; Value where inventory needs refill
(define low-quantity
  (lambda (lst)
    (filter (lambda (sublst) (< (string->number (cadddr sublst)) 5)) lst)))

;; Matches a row and a col based on a letter and index
(define match-row-col
  (lambda (row-match index)
    (car(filter (lambda (row) (equal? (string->number index) (string->number(caddr row)))) row-match))))

;; Matches a row and a col based on a product
(define match-row-col-product
  (lambda (row-match string)
    (car(filter (lambda (row) (equal? (substring string 0 2) (car row))) row-match))))

;; Increase or decrease ASCII char based on passed char
(define (move-char c symbol)
  (integer->char (symbol (char->integer c) 1)))

;; Generate the right col
(define get-col-right
  (lambda (inventory)
    (map last (map cdr inventory))))

;; Generate the left col
(define get-col-left
  (lambda (inventory)
    (map (lambda (sublist) (last sublist))inventory)))

;; Minimum recursive calls
(define min-recursive-steps
  (lambda (list)(assoc(apply min (map car list))list)))

;; Replace window to string
(define (space-separated-string list)
  (string-join list " "))

;; Check for substrings
;; -1 substr(0, 1)
;; 0 substr(1, 2)
;; 1 substr(0, 2)
(define get-letter-index-window
    (lambda (window flag)
     (cond  ((equal? flag -1) (substring (car window) 0 1))
            ((equal? flag 0)(substring(car window) 1 2))
            ((equal? flag 1)(substring(car window) 0 2)))))

;; Check for substrings
;; -1 substr(0, 1)
;; 1 substr(0, 2)
(define get-product-letter-index
    (lambda (product flag)
     (cond ((equal? flag -1) (substring product 0 1))
           ((equal? flag 1) (substring product 0 2)))))

;; Generate letter when rows and window passed
(define get-letter-match
    (lambda (row window)
      (car(filter(lambda (rows) (equal? rows (substring (car window) 0 1)))row))))

;; Move to the left or right based on passed flag
;; 0 go to the left
;; 1 go to the right
(define (move-left-right inventory window flag)
  (cond ((null? inventory) window) ; Look for row where window belongs 
        ((equal? flag 0)(look-inventory (get-letter-match (generate-row inventory) window) (- (string->number(caddr window)) 1)
                                        (generate-rows inventory (get-letter-match (generate-row inventory) window))))
        ((equal? flag 1)(look-inventory (get-letter-match (generate-row inventory) window)(+ (string->number(caddr window)) 1)
                                        (generate-rows inventory (get-letter-match (generate-row inventory) window))))
        (else (move-left-right (cdr inventory) window flag))))

;; Move up or down based on passed symbol
;; - go up
;; + go down
(define (move-up-down inventory window symbol)
    (cond ((null? inventory) window)
    ((and(equal? (substring (get-letter-match (generate-row inventory) window) 0 1) "A") (equal? symbol -))
    (match-row-col (generate-rows inventory "G") (caddr window)))
    ((and(equal? (substring (get-letter-match (generate-row inventory) window) 0 1) "G") (equal? symbol +))
    (match-row-col (generate-rows inventory "A") (caddr window)))
    (else(match-row-col (generate-rows inventory (string(move-char (string-ref(get-letter-match (generate-row inventory) window) 0) symbol)))(caddr window)))))

;; Look for same indexes in inventary
;; Return window at position
(define (look-inventory row index window)
  (cond ((null? window) null)
        ((equal?(string->number (caddar window)) index) ; Look for same indexes and rows return the last window
         (car window))
        (else (look-inventory row index (cdr window)))))

;; Min steps to get to a product
;; First go up, then down.
;; For each of those go left and right till out of bounds
;; If out of bounds, just return the other list with the counter
(define (min-steps-to-product rows product quantity inventory window symbol)
  (cond ((null? inventory) null)
        ((null? product) (add-retire-product null quantity window symbol))
        ((equal? (car rows) (get-product-letter-index product -1)) ; Identify the row where the product is
         (let ((min-up (min-to-row-up-down(get-letter-match (generate-row inventory) window) inventory window product -)) ; Get the minimum steps to match the letter down the road
               (min-down (min-to-row-up-down (get-letter-match (generate-row inventory) window) inventory window product +))) ; Get the minimum steps to match the letter up the road
           (cond ((null? (cdr min-up))(min-down)) ; If one of both is null return de other one
                 ((null? (cdr min-down))(min-up))
                 (else (add-retire-product product quantity (list min-up min-down) symbol)))))
        (else (min-steps-to-product (cdr rows) product quantity inventory window symbol))))

;; Retire product with the min possible steps to get
;; there from a starting position
(define (add-retire-product product quantity list-steps-window symbol)
  (cond ((null? product)
          (let ((result (symbol (string->number(cadddr list-steps-window)) quantity)))
                (cond ((< result 0)
                (define modified-window (list (car list-steps-window) (cadr list-steps-window) (caddr list-steps-window) (number->string 0)))
                (display (string-append "Rellena este producto! " (number->string result) " del producto " (car list-steps-window)))
                    (newline)
                    (modify-file "Inventory.txt" modified-window))
              (else (define modified-window (list (car list-steps-window) (cadr list-steps-window) (caddr list-steps-window) (number->string result)))
                    (display (string-append "Queda: " (number->string result) " del producto " (car list-steps-window)))
                    (newline)
                    (modify-file "Inventory.txt" modified-window)))))
        (else (let ((result (symbol (string->number (cadr(cddadr (min-recursive-steps list-steps-window)))) quantity)))
          (cond (( < result 0) (define modified-window (list (caadar list-steps-window) (car(cdadar list-steps-window)) (cadr(cdadar list-steps-window)) (number->string 0)))
                 (display(string-append "Queda: " (number->string 0) " del producto: " product " RELLENA al producto " product". Transacción hecha con los siguientes pasos: "
                      (number->string (car(min-recursive-steps list-steps-window)))))
                      (newline)
                      (modify-file "Inventory.txt" modified-window)
                     (newline))                   ; Product name                ; Price                      ; index                          ; quantity 
                (else (define modified-window (list (caadar list-steps-window) (car(cdadar list-steps-window)) (cadr(cdadar list-steps-window)) (number->string result) ))
                 (display(string-append "Queda: " (number->string result) " del producto: " product ". Transacción hecha con los siguientes pasos: "
                          (number->string (car(min-recursive-steps list-steps-window)))))
                          (newline)
                          (modify-file "Inventory.txt" modified-window)(newline)))))))


;; Receive inventory and window
;; Calls move-up-down with - to move one cell up
(define (U inventory window)
  (cond ((null? inventory) null)
        (else (move-up-down inventory window -))))

;; Receive inventory and window
;; Calls move-up-down with + to move one cell down
(define (D inventory window)
  (cond ((null? inventory) null)
        (else (move-up-down inventory window +))))

;; Receive inventory and window
;; Calls move-left-right if not out of bounds with 0 to move left
(define (L inventory window)
  (cond ((null? inventory) null)
        ((out-of-bounds (get-col-left inventory) window -1) null)
        (else(move-left-right inventory window 0))))

;; Receive inventory and window
;; Calls move-left-right if not out of bounds with 1 to move right
(define (R inventory window)
  (cond ((null? inventory) null)
        ((out-of-bounds (get-col-right inventory) window 1) null)
        (else(move-left-right inventory window 1))))

;; Iterate to the check if out of bounds, return true if out of bounds
(define (out-of-bounds left-right-col window symbol)
  (cond ((null? left-right-col)#f)
        ((and(equal? symbol -1)(regexp-match? left-regex (car window)))#t)
        ((and(equal? symbol 1)(regexp-match? right-regex (car window)))#t)
        (else (out-of-bounds (cdr left-right-col) window symbol))))

;; Evaluate till the product is found to the left or right
;; Return the steps to get there
;; -1 move left
;; 1 move right
(define (min-check-cols-left-right inventory window product movement)
    (cond ((null? window)(list 0 window))
      ((equal? (get-letter-index-window window 1) (get-product-letter-index product 1)) (list 0 window))
      ((equal? movement -1)
       (let((result (min-check-cols-left-right inventory (L inventory window) product movement)))(cons(+ 1 (car result)) (cdr result))))
    (else (let((result (min-check-cols-left-right inventory (R inventory window) product movement)))
         (cons(+ 1 (car result)) (cdr result))))))

;; Modify the file with the file path
;; Receives the modified window  
(define (modify-file file-path window)
  ;; Open the input file
  (define input-port (open-input-file file-path))

  (define (replace-line line)
    (if (string=? (car line) (car window))
        (list (space-separated-string window))
        line))

  ;; Read and replace the desired line
  (define lines (list))
  (let loop ((line (read-line input-port)))
    (if (not (eof-object? line))
        (begin
          (set! lines (append lines (list (replace-line (string-split line " ")))))
          (loop (read-line input-port)))
        (void)))

  ;; Close the input file
  (close-input-port input-port)

  ;; Delete the output file if it already exists
  (if (file-exists? "Inventory.txt")
      (delete-file "Inventory.txt")
      #f)

  ;; Open the output file
  (define output-port (open-output-file "Inventory.txt"))

  ;; Write the modified list back to the file
  (for-each (lambda (line) (displayln (string-join line " ") output-port)) lines)
  ;; Close the output file

  (close-output-port output-port)
  
  (define open2 (open-input-file file-path))
  (define lines-new (list))
  (let loop ((line (read-line open2)))
    (if (not (eof-object? line))
        (begin
          (set! lines-new (append lines-new (list (string-split line " "))))
          (loop (read-line open2)))
        (void)))
  (close-input-port open2)
  (display "El valor del inventario de medicinas es: ")
  (display (suma-inventario-precio lines-new))
  (newline)
  (display "Los siguientes productos necesitan un refill: ")
  (display (low-quantity lines-new))
)

;; Evaluate till the product is found to the right
;; Return the steps to get there
;; returns left or right steps based on the results
(define (min-check-cols inventory window product)
  (cond ((equal? (get-letter-index-window window 1) (get-product-letter-index product 1)) (list 0 window))
        ((equal? (get-letter-index-window window 0) "1")
         (let ((result-right(min-check-cols-left-right inventory (R inventory window) product 1)))(cons (+ 1 (car result-right)) (cdr result-right))))
        ((equal? (get-letter-index-window window 0) "5")
         (let ((result-left(min-check-cols-left-right inventory (L inventory window) product -1)))(cons (+ 1 (car result-left)) (cdr result-left))))
        (else(let((result-right (min-check-cols-left-right inventory (R inventory window) product 1))
        (result-left (min-check-cols-left-right inventory (L inventory window) product -1)))
           (cond ((null? (cdr result-right)) (cons(+ 1 (car result-left)) (cdr result-left)))
                (else (cons (+ 1 (car result-right)) (cdr result-right))))))))

;; Evaluate till the row is found upwards
;; return the sum of the steps and the state at the window
(define (min-to-row-up-down letter inventory window product symbol)
  (cond ((equal? (get-letter-index-window window -1) (get-product-letter-index product -1))(min-check-cols inventory window product))
  ((equal? symbol -) (let ((result (min-to-row-up-down letter inventory (U inventory window) product symbol)))(cons(+ 1 (car result)) (cdr result))))
  (else (let((result (min-to-row-up-down letter inventory (D inventory window) product symbol)))(cons(+ 1 (car result)) (cdr result))))))

(define (read-file file-path)
  (call-with-input-file file-path
    (lambda (port)
      (let loop ((line (read-line port))
                 (result '()))
        (if (eof-object? line)
            (reverse result)
            (loop (read-line port)
                  (cons (string-split line) result)))))))

(define file-lines (read-file "Inventory.txt"))

(define rows-A
  (lambda (rows)
    (let ((a-rows (filter (lambda (row) (equal? (substring (car row) 0 1) "A")) rows))
          (result '()))
      (set! result (cons "A" (map (lambda (sublist) (apply list sublist)) a-rows)))
      result)))
(define rows-B
  (lambda (rows)
    (let ((b-rows (filter (lambda (row) (equal? (substring (car row) 0 1) "B")) rows))
          (result '()))
      (set! result (cons "B" (map (lambda (sublist) (apply list sublist)) b-rows)))
      result)))
(define rows-C
  (lambda (rows)
    (let ((c-rows (filter (lambda (row) (equal? (substring (car row) 0 1) "C")) rows))
          (result '()))
      (set! result (cons "C" (map (lambda (sublist) (apply list sublist)) c-rows)))
      result)))
(define rows-D
  (lambda (rows)
    (let ((d-rows (filter (lambda (row) (equal? (substring (car row) 0 1) "D")) rows))
          (result '()))
      (set! result (cons "D" (map (lambda (sublist) (apply list sublist)) d-rows)))
      result)))
(define rows-E
  (lambda (rows)
    (let ((e-rows (filter (lambda (row) (equal? (substring (car row) 0 1) "E")) rows))
          (result '()))
      (set! result (cons "E" (map (lambda (sublist) (apply list sublist)) e-rows)))
      result)))
(define rows-F
  (lambda (rows)
    (let ((f-rows (filter (lambda (row) (equal? (substring (car row) 0 1) "F")) rows))
          (result '()))
      (set! result (cons "F" (map (lambda (sublist) (apply list sublist)) f-rows)))
      result)))
(define rows-G
  (lambda (rows)
    (let ((g-rows (filter (lambda (row) (equal? (substring (car row) 0 1) "G")) rows))
          (result '()))
      (set! result (cons "G" (map (lambda (sublist) (apply list sublist)) g-rows)))
      result)))

(define inventary (list (rows-A file-lines) (rows-B file-lines) (rows-C file-lines) (rows-D file-lines) (rows-E file-lines) (rows-F file-lines)(rows-G file-lines) ))
(display "Subir desde ventanilla A1: ")
(display (U inventary (list "A1" 100 "1" 15)))(newline)
(display "Agregar producto a C2 2 cantidades desde ventanilla A1: ")
(min-steps-to-product (generate-row inventary) "C2" 2 inventary (list "A1" 100 "1") +)
(newline)
(display "Retirar producto a E4 2 cantidades desde ventanilla A1: ")
(min-steps-to-product (generate-row inventary) "E4" 2 inventary (list "A1" 100 "1") -)
(newline)
(display "Agregar producto a C4 10 cantidades desde ventanilla D2: ")
(min-steps-to-product (generate-row inventary) "C4" 10 inventary (list "D2" 200 "2") +)
(newline)
(display "Agregar producto a B4 10 cantidades desde ventanilla D2: ")
(min-steps-to-product (generate-row inventary) "B4" 10 inventary (list "D2" 200 "2") +)
(newline)
(display "Agregar al elemento en ventanilla C2: 10 unidades Aplicando subir desde ventanilla D2: ")
(newline)
(min-steps-to-product (generate-row inventary) null 10 inventary (U inventary (list "D2" 200 "2" 15))+)
(newline)
(display "Agregar al producto en ventanilla F2: 10 unidades Aplicando subir desde ventanilla C3: ")
(min-steps-to-product (generate-row inventary) "C3" 10 inventary (list "F2" 200 "2") +)