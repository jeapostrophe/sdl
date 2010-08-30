#lang racket
(require ffi/unsafe)

; XXX Can't link because racket isn't 64bit
(define libSDL (ffi-lib "/opt/local/lib/libSDL"))

