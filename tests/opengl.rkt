#lang racket
(require "../sdl.rkt"
         sgl
         sgl/gl-vectors)

(define WIDTH 640)
(define HEIGHT 480)

; Setup SDL
(SDL_Init SDL_INIT_VIDEO)

(atexit SDL_Quit)

(define video (SDL_GetVideoInfo))

(SDL_GL_SetAttribute SDL_GL_RED_SIZE 5)
(SDL_GL_SetAttribute SDL_GL_GREEN_SIZE 5)
(SDL_GL_SetAttribute SDL_GL_BLUE_SIZE 5)
(SDL_GL_SetAttribute SDL_GL_DEPTH_SIZE 16)
(SDL_GL_SetAttribute SDL_GL_DOUBLEBUFFER 1)

(SDL_SetVideoMode WIDTH HEIGHT (SDL_PixelFormat-BitsPerPixel (SDL_VideoInfo-vfmt video)) SDL_OPENGL)

; Setup OpenGL
(define aspect (/ WIDTH HEIGHT))

(glViewport 0 0 WIDTH HEIGHT)
(glMatrixMode GL_PROJECTION)
(glLoadIdentity)

(gluPerspective 60.0 aspect 0.1 100.0)
(glMatrixMode GL_MODELVIEW)

(glClearColor 0.5 0.5 0.5 0)

(glEnable GL_DEPTH_TEST)

(glDisable GL_CULL_FACE)

; Main
(define yaw 45)
(define pitch 0)
(define level 2)

(define point
  (vector (gl-float-vector 1.0 0.0 0.0) (gl-float-vector -1.0 0.0 0.0)
          (gl-float-vector 0.0 1.0 0.0) (gl-float-vector 0.0 -1.0 0.0)
          (gl-float-vector 0.0 0.0 1.0) (gl-float-vector 0.0 0.0 -1.0)))

(define (subdivide point0 point1 point2 level)
  (if (zero? level)
      (for ([point (in-list point0 point1 point2)])
        (glColor3fv point)
        (glVertex3fv point))
      (local [(define midpoint
                (vector (gl-vector 0.0 0.0 0.0)
                        (gl-vector 0.0 0.0 0.0)
                        (gl-vector 0.0 0.0 0.0)))
              (define nlevel (sub1 level))]
        (for ([coord (in-range 3)])
          (gl-vector-set! (vector-ref midpoint 0) coord
                          (* 0.5
                             (+ (gl-vector-ref point0 coord)
                                (gl-vector-ref point1 coord))))          
          (gl-vector-set! (vector-ref midpoint 1) coord
                          (* 0.5
                             (+ (gl-vector-ref point1 coord)
                                (gl-vector-ref point2 coord))))          
          (gl-vector-set! (vector-ref midpoint 2) coord
                          (* 0.5
                             (+ (gl-vector-ref point2 coord)
                                (gl-vector-ref point0 coord)))))
        (subdivide point0 (vector-ref midpoint 0) (vector-ref midpoint 2) nlevel)
        (subdivide point1 (vector-ref midpoint 1) (vector-ref midpoint 0) nlevel)
        (subdivide point2 (vector-ref midpoint 2) (vector-ref midpoint 1) nlevel))))

(define (repaint)
  (glClear GL_COLOR_BUFFER_BIT GL_DEPTH_BUFFER_BIT)
  (glLoadIdentity)
  (glTranslatef 0.0 0.0 -2.0)
  (glRotatef pitch 1.0 0.0 0.0)
  (glRotatef yaw 0.0 1.0 0.0)
  (glBegin GL_TRIANGLES)
  (for ([i*j*k (in-list
                (list (vector 2 4 0)
                      (vector 2 0 5)
                      (vector 2 5 1)
                      (vector 2 1 4)
                      (vector 3 0 4)
                      (vector 3 5 0)
                      (vector 3 1 5)
                      (vector 3 4 1)))])
    (match-define (vector i j k) i*j*k)
    (subdivide (vector-ref point i)
               (vector-ref point j)
               (vector-ref point k)
               level))
  (glEnd)
  (set! yaw (+ yaw 0.05))
  (SDL_GL_SwapBuffers))

(let main-loop ()
  (let poll-loop ()
    (define event (SDL_PollEvent))
    (when event
      (local [(define ty (event-type event))]
        ; XXX
        (pool-loop))))
  (repaint)
  (SDL_Delay 50)
  (main-loop))