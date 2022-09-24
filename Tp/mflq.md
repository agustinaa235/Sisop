# Desafío Scheduling avanzado

### Round Robin
El algoritmo de round robin consiste en ejecutar un proceso por un periodo de tiempo determinado (time slice) y transcurrido
ese tiempo pasa a otro proceso en la cola de ejecución.(En este caso trata a todos los procesos por igual).
Para poder simularlo se indicaron ciertos parametros o flags:
 * El flags `-n` que indica la cantidad de colas. En este caso n es igual a 1 ya que en round robin hay una única cola de
   ejecución.
 * El flags `-q` indica el time slice para todas las colas, en este caso es una sola.
 * El flag `-j` indica el número de jobs a ejecutar. Este numero no afecta al algoritmo de round robin, es arbitrario.
 * El flag `-M` indica la maxima frecuencia de I/O. En este caso es 0 ya que no se tiene en cuenta el I/O.
 * El flags `-i` indica el I/O time pero como pusimos el flag -M 0 no es necesario ponerlo a cero.

ej:
``` console
./mlfq.py -c  -j 3 -n 1 -M 0 -q 10

      Here is the list of inputs:
      OPTIONS jobs 3
      OPTIONS queues 1
      OPTIONS allotments for queue  0 is   1
      OPTIONS quantum length for queue  0 is  10
      OPTIONS boost 0
      OPTIONS ioTime 5
      OPTIONS stayAfterIO False
      OPTIONS iobump False


      For each job, three defining characteristics are given:
        startTime : at what time does the job enter the system
        runTime   : the total CPU time needed by the job to finish
        ioFreq    : every ioFreq time units, the job issues an I/O
                    (the I/O takes ioTime units to complete)

      Job List:
        Job  0: startTime   0 - runTime  84 - ioFreq   0
        Job  1: startTime   0 - runTime  42 - ioFreq   0
        Job  2: startTime   0 - runTime  51 - ioFreq   0


      Execution Trace:

      [ time 0 ] JOB BEGINS by JOB 0
      [ time 0 ] JOB BEGINS by JOB 1
      [ time 0 ] JOB BEGINS by JOB 2
      [ time 0 ] Run JOB 0 at PRIORITY 0 [ TICKS 9 ALLOT 1 TIME 83 (of 84) ]
      [ time 1 ] Run JOB 0 at PRIORITY 0 [ TICKS 8 ALLOT 1 TIME 82 (of 84) ]
      [ time 2 ] Run JOB 0 at PRIORITY 0 [ TICKS 7 ALLOT 1 TIME 81 (of 84) ]
      [ time 3 ] Run JOB 0 at PRIORITY 0 [ TICKS 6 ALLOT 1 TIME 80 (of 84) ]
      [ time 4 ] Run JOB 0 at PRIORITY 0 [ TICKS 5 ALLOT 1 TIME 79 (of 84) ]
      [ time 5 ] Run JOB 0 at PRIORITY 0 [ TICKS 4 ALLOT 1 TIME 78 (of 84) ]
      [ time 6 ] Run JOB 0 at PRIORITY 0 [ TICKS 3 ALLOT 1 TIME 77 (of 84) ]
      [ time 7 ] Run JOB 0 at PRIORITY 0 [ TICKS 2 ALLOT 1 TIME 76 (of 84) ]
      [ time 8 ] Run JOB 0 at PRIORITY 0 [ TICKS 1 ALLOT 1 TIME 75 (of 84) ]
      [ time 9 ] Run JOB 0 at PRIORITY 0 [ TICKS 0 ALLOT 1 TIME 74 (of 84) ]
      [ time 10 ] Run JOB 1 at PRIORITY 0 [ TICKS 9 ALLOT 1 TIME 41 (of 42) ]
      [ time 11 ] Run JOB 1 at PRIORITY 0 [ TICKS 8 ALLOT 1 TIME 40 (of 42) ]
      [ time 12 ] Run JOB 1 at PRIORITY 0 [ TICKS 7 ALLOT 1 TIME 39 (of 42) ]
      [ time 13 ] Run JOB 1 at PRIORITY 0 [ TICKS 6 ALLOT 1 TIME 38 (of 42) ]
      [ time 14 ] Run JOB 1 at PRIORITY 0 [ TICKS 5 ALLOT 1 TIME 37 (of 42) ]
      [ time 15 ] Run JOB 1 at PRIORITY 0 [ TICKS 4 ALLOT 1 TIME 36 (of 42) ]
      [ time 16 ] Run JOB 1 at PRIORITY 0 [ TICKS 3 ALLOT 1 TIME 35 (of 42) ]
      [ time 17 ] Run JOB 1 at PRIORITY 0 [ TICKS 2 ALLOT 1 TIME 34 (of 42) ]
      [ time 18 ] Run JOB 1 at PRIORITY 0 [ TICKS 1 ALLOT 1 TIME 33 (of 42) ]
      [ time 19 ] Run JOB 1 at PRIORITY 0 [ TICKS 0 ALLOT 1 TIME 32 (of 42) ]
      [ time 20 ] Run JOB 2 at PRIORITY 0 [ TICKS 9 ALLOT 1 TIME 50 (of 51) ]
      [ time 21 ] Run JOB 2 at PRIORITY 0 [ TICKS 8 ALLOT 1 TIME 49 (of 51) ]
      [ time 22 ] Run JOB 2 at PRIORITY 0 [ TICKS 7 ALLOT 1 TIME 48 (of 51) ]
      [ time 23 ] Run JOB 2 at PRIORITY 0 [ TICKS 6 ALLOT 1 TIME 47 (of 51) ]
      [ time 24 ] Run JOB 2 at PRIORITY 0 [ TICKS 5 ALLOT 1 TIME 46 (of 51) ]
      [ time 25 ] Run JOB 2 at PRIORITY 0 [ TICKS 4 ALLOT 1 TIME 45 (of 51) ]
      [ time 26 ] Run JOB 2 at PRIORITY 0 [ TICKS 3 ALLOT 1 TIME 44 (of 51) ]
      [ time 27 ] Run JOB 2 at PRIORITY 0 [ TICKS 2 ALLOT 1 TIME 43 (of 51) ]
      [ time 28 ] Run JOB 2 at PRIORITY 0 [ TICKS 1 ALLOT 1 TIME 42 (of 51) ]
      [ time 29 ] Run JOB 2 at PRIORITY 0 [ TICKS 0 ALLOT 1 TIME 41 (of 51) ]
      [ time 30 ] Run JOB 0 at PRIORITY 0 [ TICKS 9 ALLOT 1 TIME 73 (of 84) ]
      [ time 31 ] Run JOB 0 at PRIORITY 0 [ TICKS 8 ALLOT 1 TIME 72 (of 84) ]
      [ time 32 ] Run JOB 0 at PRIORITY 0 [ TICKS 7 ALLOT 1 TIME 71 (of 84) ]
      [ time 33 ] Run JOB 0 at PRIORITY 0 [ TICKS 6 ALLOT 1 TIME 70 (of 84) ]
      [ time 34 ] Run JOB 0 at PRIORITY 0 [ TICKS 5 ALLOT 1 TIME 69 (of 84) ]
      [ time 35 ] Run JOB 0 at PRIORITY 0 [ TICKS 4 ALLOT 1 TIME 68 (of 84) ]
      [ time 36 ] Run JOB 0 at PRIORITY 0 [ TICKS 3 ALLOT 1 TIME 67 (of 84) ]
      [ time 37 ] Run JOB 0 at PRIORITY 0 [ TICKS 2 ALLOT 1 TIME 66 (of 84) ]
      [ time 38 ] Run JOB 0 at PRIORITY 0 [ TICKS 1 ALLOT 1 TIME 65 (of 84) ]
      [ time 39 ] Run JOB 0 at PRIORITY 0 [ TICKS 0 ALLOT 1 TIME 64 (of 84) ]
      [ time 40 ] Run JOB 1 at PRIORITY 0 [ TICKS 9 ALLOT 1 TIME 31 (of 42) ]
      [ time 41 ] Run JOB 1 at PRIORITY 0 [ TICKS 8 ALLOT 1 TIME 30 (of 42) ]
      [ time 42 ] Run JOB 1 at PRIORITY 0 [ TICKS 7 ALLOT 1 TIME 29 (of 42) ]
      [ time 43 ] Run JOB 1 at PRIORITY 0 [ TICKS 6 ALLOT 1 TIME 28 (of 42) ]
      [ time 44 ] Run JOB 1 at PRIORITY 0 [ TICKS 5 ALLOT 1 TIME 27 (of 42) ]
      [ time 45 ] Run JOB 1 at PRIORITY 0 [ TICKS 4 ALLOT 1 TIME 26 (of 42) ]
      [ time 46 ] Run JOB 1 at PRIORITY 0 [ TICKS 3 ALLOT 1 TIME 25 (of 42) ]
      [ time 47 ] Run JOB 1 at PRIORITY 0 [ TICKS 2 ALLOT 1 TIME 24 (of 42) ]
      [ time 48 ] Run JOB 1 at PRIORITY 0 [ TICKS 1 ALLOT 1 TIME 23 (of 42) ]
      [ time 49 ] Run JOB 1 at PRIORITY 0 [ TICKS 0 ALLOT 1 TIME 22 (of 42) ]
      [ time 50 ] Run JOB 2 at PRIORITY 0 [ TICKS 9 ALLOT 1 TIME 40 (of 51) ]
      [ time 51 ] Run JOB 2 at PRIORITY 0 [ TICKS 8 ALLOT 1 TIME 39 (of 51) ]
      [ time 52 ] Run JOB 2 at PRIORITY 0 [ TICKS 7 ALLOT 1 TIME 38 (of 51) ]
      [ time 53 ] Run JOB 2 at PRIORITY 0 [ TICKS 6 ALLOT 1 TIME 37 (of 51) ]
      [ time 54 ] Run JOB 2 at PRIORITY 0 [ TICKS 5 ALLOT 1 TIME 36 (of 51) ]
      [ time 55 ] Run JOB 2 at PRIORITY 0 [ TICKS 4 ALLOT 1 TIME 35 (of 51) ]
      [ time 56 ] Run JOB 2 at PRIORITY 0 [ TICKS 3 ALLOT 1 TIME 34 (of 51) ]
      [ time 57 ] Run JOB 2 at PRIORITY 0 [ TICKS 2 ALLOT 1 TIME 33 (of 51) ]
      [ time 58 ] Run JOB 2 at PRIORITY 0 [ TICKS 1 ALLOT 1 TIME 32 (of 51) ]
      [ time 59 ] Run JOB 2 at PRIORITY 0 [ TICKS 0 ALLOT 1 TIME 31 (of 51) ]
      [ time 60 ] Run JOB 0 at PRIORITY 0 [ TICKS 9 ALLOT 1 TIME 63 (of 84) ]
      [ time 61 ] Run JOB 0 at PRIORITY 0 [ TICKS 8 ALLOT 1 TIME 62 (of 84) ]
      [ time 62 ] Run JOB 0 at PRIORITY 0 [ TICKS 7 ALLOT 1 TIME 61 (of 84) ]
      [ time 63 ] Run JOB 0 at PRIORITY 0 [ TICKS 6 ALLOT 1 TIME 60 (of 84) ]
      [ time 64 ] Run JOB 0 at PRIORITY 0 [ TICKS 5 ALLOT 1 TIME 59 (of 84) ]
      [ time 65 ] Run JOB 0 at PRIORITY 0 [ TICKS 4 ALLOT 1 TIME 58 (of 84) ]
      [ time 66 ] Run JOB 0 at PRIORITY 0 [ TICKS 3 ALLOT 1 TIME 57 (of 84) ]
      [ time 67 ] Run JOB 0 at PRIORITY 0 [ TICKS 2 ALLOT 1 TIME 56 (of 84) ]
      [ time 68 ] Run JOB 0 at PRIORITY 0 [ TICKS 1 ALLOT 1 TIME 55 (of 84) ]
      [ time 69 ] Run JOB 0 at PRIORITY 0 [ TICKS 0 ALLOT 1 TIME 54 (of 84) ]
      [ time 70 ] Run JOB 1 at PRIORITY 0 [ TICKS 9 ALLOT 1 TIME 21 (of 42) ]
      [ time 71 ] Run JOB 1 at PRIORITY 0 [ TICKS 8 ALLOT 1 TIME 20 (of 42) ]
      [ time 72 ] Run JOB 1 at PRIORITY 0 [ TICKS 7 ALLOT 1 TIME 19 (of 42) ]
      [ time 73 ] Run JOB 1 at PRIORITY 0 [ TICKS 6 ALLOT 1 TIME 18 (of 42) ]
      [ time 74 ] Run JOB 1 at PRIORITY 0 [ TICKS 5 ALLOT 1 TIME 17 (of 42) ]
      [ time 75 ] Run JOB 1 at PRIORITY 0 [ TICKS 4 ALLOT 1 TIME 16 (of 42) ]
      [ time 76 ] Run JOB 1 at PRIORITY 0 [ TICKS 3 ALLOT 1 TIME 15 (of 42) ]
      [ time 77 ] Run JOB 1 at PRIORITY 0 [ TICKS 2 ALLOT 1 TIME 14 (of 42) ]
      [ time 78 ] Run JOB 1 at PRIORITY 0 [ TICKS 1 ALLOT 1 TIME 13 (of 42) ]
      [ time 79 ] Run JOB 1 at PRIORITY 0 [ TICKS 0 ALLOT 1 TIME 12 (of 42) ]
      [ time 80 ] Run JOB 2 at PRIORITY 0 [ TICKS 9 ALLOT 1 TIME 30 (of 51) ]
      [ time 81 ] Run JOB 2 at PRIORITY 0 [ TICKS 8 ALLOT 1 TIME 29 (of 51) ]
      [ time 82 ] Run JOB 2 at PRIORITY 0 [ TICKS 7 ALLOT 1 TIME 28 (of 51) ]
      [ time 83 ] Run JOB 2 at PRIORITY 0 [ TICKS 6 ALLOT 1 TIME 27 (of 51) ]
      [ time 84 ] Run JOB 2 at PRIORITY 0 [ TICKS 5 ALLOT 1 TIME 26 (of 51) ]
      [ time 85 ] Run JOB 2 at PRIORITY 0 [ TICKS 4 ALLOT 1 TIME 25 (of 51) ]
      [ time 86 ] Run JOB 2 at PRIORITY 0 [ TICKS 3 ALLOT 1 TIME 24 (of 51) ]
      [ time 87 ] Run JOB 2 at PRIORITY 0 [ TICKS 2 ALLOT 1 TIME 23 (of 51) ]
      [ time 88 ] Run JOB 2 at PRIORITY 0 [ TICKS 1 ALLOT 1 TIME 22 (of 51) ]
      [ time 89 ] Run JOB 2 at PRIORITY 0 [ TICKS 0 ALLOT 1 TIME 21 (of 51) ]
      [ time 90 ] Run JOB 0 at PRIORITY 0 [ TICKS 9 ALLOT 1 TIME 53 (of 84) ]
      [ time 91 ] Run JOB 0 at PRIORITY 0 [ TICKS 8 ALLOT 1 TIME 52 (of 84) ]
      [ time 92 ] Run JOB 0 at PRIORITY 0 [ TICKS 7 ALLOT 1 TIME 51 (of 84) ]
      [ time 93 ] Run JOB 0 at PRIORITY 0 [ TICKS 6 ALLOT 1 TIME 50 (of 84) ]
      [ time 94 ] Run JOB 0 at PRIORITY 0 [ TICKS 5 ALLOT 1 TIME 49 (of 84) ]
      [ time 95 ] Run JOB 0 at PRIORITY 0 [ TICKS 4 ALLOT 1 TIME 48 (of 84) ]
      [ time 96 ] Run JOB 0 at PRIORITY 0 [ TICKS 3 ALLOT 1 TIME 47 (of 84) ]
      [ time 97 ] Run JOB 0 at PRIORITY 0 [ TICKS 2 ALLOT 1 TIME 46 (of 84) ]
      [ time 98 ] Run JOB 0 at PRIORITY 0 [ TICKS 1 ALLOT 1 TIME 45 (of 84) ]
      [ time 99 ] Run JOB 0 at PRIORITY 0 [ TICKS 0 ALLOT 1 TIME 44 (of 84) ]
      [ time 100 ] Run JOB 1 at PRIORITY 0 [ TICKS 9 ALLOT 1 TIME 11 (of 42) ]
      [ time 101 ] Run JOB 1 at PRIORITY 0 [ TICKS 8 ALLOT 1 TIME 10 (of 42) ]
      [ time 102 ] Run JOB 1 at PRIORITY 0 [ TICKS 7 ALLOT 1 TIME 9 (of 42) ]
      [ time 103 ] Run JOB 1 at PRIORITY 0 [ TICKS 6 ALLOT 1 TIME 8 (of 42) ]
      [ time 104 ] Run JOB 1 at PRIORITY 0 [ TICKS 5 ALLOT 1 TIME 7 (of 42) ]
      [ time 105 ] Run JOB 1 at PRIORITY 0 [ TICKS 4 ALLOT 1 TIME 6 (of 42) ]
      [ time 106 ] Run JOB 1 at PRIORITY 0 [ TICKS 3 ALLOT 1 TIME 5 (of 42) ]
      [ time 107 ] Run JOB 1 at PRIORITY 0 [ TICKS 2 ALLOT 1 TIME 4 (of 42) ]
      [ time 108 ] Run JOB 1 at PRIORITY 0 [ TICKS 1 ALLOT 1 TIME 3 (of 42) ]
      [ time 109 ] Run JOB 1 at PRIORITY 0 [ TICKS 0 ALLOT 1 TIME 2 (of 42) ]
      [ time 110 ] Run JOB 2 at PRIORITY 0 [ TICKS 9 ALLOT 1 TIME 20 (of 51) ]
      [ time 111 ] Run JOB 2 at PRIORITY 0 [ TICKS 8 ALLOT 1 TIME 19 (of 51) ]
      [ time 112 ] Run JOB 2 at PRIORITY 0 [ TICKS 7 ALLOT 1 TIME 18 (of 51) ]
      [ time 113 ] Run JOB 2 at PRIORITY 0 [ TICKS 6 ALLOT 1 TIME 17 (of 51) ]
      [ time 114 ] Run JOB 2 at PRIORITY 0 [ TICKS 5 ALLOT 1 TIME 16 (of 51) ]
      [ time 115 ] Run JOB 2 at PRIORITY 0 [ TICKS 4 ALLOT 1 TIME 15 (of 51) ]
      [ time 116 ] Run JOB 2 at PRIORITY 0 [ TICKS 3 ALLOT 1 TIME 14 (of 51) ]
      [ time 117 ] Run JOB 2 at PRIORITY 0 [ TICKS 2 ALLOT 1 TIME 13 (of 51) ]
      [ time 118 ] Run JOB 2 at PRIORITY 0 [ TICKS 1 ALLOT 1 TIME 12 (of 51) ]
      [ time 119 ] Run JOB 2 at PRIORITY 0 [ TICKS 0 ALLOT 1 TIME 11 (of 51) ]
      [ time 120 ] Run JOB 0 at PRIORITY 0 [ TICKS 9 ALLOT 1 TIME 43 (of 84) ]
      [ time 121 ] Run JOB 0 at PRIORITY 0 [ TICKS 8 ALLOT 1 TIME 42 (of 84) ]
      [ time 122 ] Run JOB 0 at PRIORITY 0 [ TICKS 7 ALLOT 1 TIME 41 (of 84) ]
      [ time 123 ] Run JOB 0 at PRIORITY 0 [ TICKS 6 ALLOT 1 TIME 40 (of 84) ]
      [ time 124 ] Run JOB 0 at PRIORITY 0 [ TICKS 5 ALLOT 1 TIME 39 (of 84) ]
      [ time 125 ] Run JOB 0 at PRIORITY 0 [ TICKS 4 ALLOT 1 TIME 38 (of 84) ]
      [ time 126 ] Run JOB 0 at PRIORITY 0 [ TICKS 3 ALLOT 1 TIME 37 (of 84) ]
      [ time 127 ] Run JOB 0 at PRIORITY 0 [ TICKS 2 ALLOT 1 TIME 36 (of 84) ]
      [ time 128 ] Run JOB 0 at PRIORITY 0 [ TICKS 1 ALLOT 1 TIME 35 (of 84) ]
      [ time 129 ] Run JOB 0 at PRIORITY 0 [ TICKS 0 ALLOT 1 TIME 34 (of 84) ]
      [ time 130 ] Run JOB 1 at PRIORITY 0 [ TICKS 9 ALLOT 1 TIME 1 (of 42) ]
      [ time 131 ] Run JOB 1 at PRIORITY 0 [ TICKS 8 ALLOT 1 TIME 0 (of 42) ]
      [ time 132 ] FINISHED JOB 1
      [ time 132 ] Run JOB 2 at PRIORITY 0 [ TICKS 9 ALLOT 1 TIME 10 (of 51) ]
      [ time 133 ] Run JOB 2 at PRIORITY 0 [ TICKS 8 ALLOT 1 TIME 9 (of 51) ]
      [ time 134 ] Run JOB 2 at PRIORITY 0 [ TICKS 7 ALLOT 1 TIME 8 (of 51) ]
      [ time 135 ] Run JOB 2 at PRIORITY 0 [ TICKS 6 ALLOT 1 TIME 7 (of 51) ]
      [ time 136 ] Run JOB 2 at PRIORITY 0 [ TICKS 5 ALLOT 1 TIME 6 (of 51) ]
      [ time 137 ] Run JOB 2 at PRIORITY 0 [ TICKS 4 ALLOT 1 TIME 5 (of 51) ]
      [ time 138 ] Run JOB 2 at PRIORITY 0 [ TICKS 3 ALLOT 1 TIME 4 (of 51) ]
      [ time 139 ] Run JOB 2 at PRIORITY 0 [ TICKS 2 ALLOT 1 TIME 3 (of 51) ]
      [ time 140 ] Run JOB 2 at PRIORITY 0 [ TICKS 1 ALLOT 1 TIME 2 (of 51) ]
      [ time 141 ] Run JOB 2 at PRIORITY 0 [ TICKS 0 ALLOT 1 TIME 1 (of 51) ]
      [ time 142 ] Run JOB 0 at PRIORITY 0 [ TICKS 9 ALLOT 1 TIME 33 (of 84) ]
      [ time 143 ] Run JOB 0 at PRIORITY 0 [ TICKS 8 ALLOT 1 TIME 32 (of 84) ]
      [ time 144 ] Run JOB 0 at PRIORITY 0 [ TICKS 7 ALLOT 1 TIME 31 (of 84) ]
      [ time 145 ] Run JOB 0 at PRIORITY 0 [ TICKS 6 ALLOT 1 TIME 30 (of 84) ]
      [ time 146 ] Run JOB 0 at PRIORITY 0 [ TICKS 5 ALLOT 1 TIME 29 (of 84) ]
      [ time 147 ] Run JOB 0 at PRIORITY 0 [ TICKS 4 ALLOT 1 TIME 28 (of 84) ]
      [ time 148 ] Run JOB 0 at PRIORITY 0 [ TICKS 3 ALLOT 1 TIME 27 (of 84) ]
      [ time 149 ] Run JOB 0 at PRIORITY 0 [ TICKS 2 ALLOT 1 TIME 26 (of 84) ]
      [ time 150 ] Run JOB 0 at PRIORITY 0 [ TICKS 1 ALLOT 1 TIME 25 (of 84) ]
      [ time 151 ] Run JOB 0 at PRIORITY 0 [ TICKS 0 ALLOT 1 TIME 24 (of 84) ]
      [ time 152 ] Run JOB 2 at PRIORITY 0 [ TICKS 9 ALLOT 1 TIME 0 (of 51) ]
      [ time 153 ] FINISHED JOB 2
      [ time 153 ] Run JOB 0 at PRIORITY 0 [ TICKS 9 ALLOT 1 TIME 23 (of 84) ]
      [ time 154 ] Run JOB 0 at PRIORITY 0 [ TICKS 8 ALLOT 1 TIME 22 (of 84) ]
      [ time 155 ] Run JOB 0 at PRIORITY 0 [ TICKS 7 ALLOT 1 TIME 21 (of 84) ]
      [ time 156 ] Run JOB 0 at PRIORITY 0 [ TICKS 6 ALLOT 1 TIME 20 (of 84) ]
      [ time 157 ] Run JOB 0 at PRIORITY 0 [ TICKS 5 ALLOT 1 TIME 19 (of 84) ]
      [ time 158 ] Run JOB 0 at PRIORITY 0 [ TICKS 4 ALLOT 1 TIME 18 (of 84) ]
      [ time 159 ] Run JOB 0 at PRIORITY 0 [ TICKS 3 ALLOT 1 TIME 17 (of 84) ]
      [ time 160 ] Run JOB 0 at PRIORITY 0 [ TICKS 2 ALLOT 1 TIME 16 (of 84) ]
      [ time 161 ] Run JOB 0 at PRIORITY 0 [ TICKS 1 ALLOT 1 TIME 15 (of 84) ]
      [ time 162 ] Run JOB 0 at PRIORITY 0 [ TICKS 0 ALLOT 1 TIME 14 (of 84) ]
      [ time 163 ] Run JOB 0 at PRIORITY 0 [ TICKS 9 ALLOT 1 TIME 13 (of 84) ]
      [ time 164 ] Run JOB 0 at PRIORITY 0 [ TICKS 8 ALLOT 1 TIME 12 (of 84) ]
      [ time 165 ] Run JOB 0 at PRIORITY 0 [ TICKS 7 ALLOT 1 TIME 11 (of 84) ]
      [ time 166 ] Run JOB 0 at PRIORITY 0 [ TICKS 6 ALLOT 1 TIME 10 (of 84) ]
      [ time 167 ] Run JOB 0 at PRIORITY 0 [ TICKS 5 ALLOT 1 TIME 9 (of 84) ]
      [ time 168 ] Run JOB 0 at PRIORITY 0 [ TICKS 4 ALLOT 1 TIME 8 (of 84) ]
      [ time 169 ] Run JOB 0 at PRIORITY 0 [ TICKS 3 ALLOT 1 TIME 7 (of 84) ]
      [ time 170 ] Run JOB 0 at PRIORITY 0 [ TICKS 2 ALLOT 1 TIME 6 (of 84) ]
      [ time 171 ] Run JOB 0 at PRIORITY 0 [ TICKS 1 ALLOT 1 TIME 5 (of 84) ]
      [ time 172 ] Run JOB 0 at PRIORITY 0 [ TICKS 0 ALLOT 1 TIME 4 (of 84) ]
      [ time 173 ] Run JOB 0 at PRIORITY 0 [ TICKS 9 ALLOT 1 TIME 3 (of 84) ]
      [ time 174 ] Run JOB 0 at PRIORITY 0 [ TICKS 8 ALLOT 1 TIME 2 (of 84) ]
      [ time 175 ] Run JOB 0 at PRIORITY 0 [ TICKS 7 ALLOT 1 TIME 1 (of 84) ]
      [ time 176 ] Run JOB 0 at PRIORITY 0 [ TICKS 6 ALLOT 1 TIME 0 (of 84) ]
      [ time 177 ] FINISHED JOB 0

      Final statistics:
        Job  0: startTime   0 - response   0 - turnaround 177
        Job  1: startTime   0 - response  10 - turnaround 132
        Job  2: startTime   0 - response  20 - turnaround 153

        Avg  2: startTime n/a - response 10.00 - turnaround 154.00
```
Primero se ejecuta el job 0 un time slice de 10 ms, luego se frena su ejecución y se pasa a ejecutar el job 1 un time slice de 10 ms, se frena su ejecución y se pasa a ejecutar el job 2 un time slice de 10 ms. Cuando termina de ejecutarse el job 2 (el time slice), como el job 0 no terminó su ejecución completa, se vuelve a ejecutar el time slice de 10 y así repetidamente hasta que van terminado su ejecución completa cada job. El primero en terminar su ejecucion es el job 1 a t = 132 ms, luego terminó su ejecución el job 2 con t = 153 ms y por ultimo el job 0 cuyo t fue 177 ms.

### MFLQ

Se propusieron dos escenarios distintos uno con I/O Y otro sin I/O. Ambos sin boost y con 3 jobs.

2.1 Primer Escenario: Se utilizaron 3 colas, todas con el mismo time slice de 10ms y un time allotment de 1. Sin I/O.

``` console
./mlfq.py -c  -j 3 -n 3 -M 0 -q 10 -a 1 -B 0

      Here is the list of inputs:
      OPTIONS jobs 3
      OPTIONS queues 3
      OPTIONS allotments for queue  2 is   1
      OPTIONS quantum length for queue  2 is  10
      OPTIONS allotments for queue  1 is   1
      OPTIONS quantum length for queue  1 is  10
      OPTIONS allotments for queue  0 is   1
      OPTIONS quantum length for queue  0 is  10
      OPTIONS boost 0
      OPTIONS ioTime 5
      OPTIONS stayAfterIO False
      OPTIONS iobump False


      For each job, three defining characteristics are given:
        startTime : at what time does the job enter the system
        runTime   : the total CPU time needed by the job to finish
        ioFreq    : every ioFreq time units, the job issues an I/O
                    (the I/O takes ioTime units to complete)

      Job List:
        Job  0: startTime   0 - runTime  84 - ioFreq   0
        Job  1: startTime   0 - runTime  42 - ioFreq   0
        Job  2: startTime   0 - runTime  51 - ioFreq   0


      Execution Trace:

      [ time 0 ] JOB BEGINS by JOB 0
      [ time 0 ] JOB BEGINS by JOB 1
      [ time 0 ] JOB BEGINS by JOB 2
      [ time 0 ] Run JOB 0 at PRIORITY 2 [ TICKS 9 ALLOT 1 TIME 83 (of 84) ]
      [ time 1 ] Run JOB 0 at PRIORITY 2 [ TICKS 8 ALLOT 1 TIME 82 (of 84) ]
      [ time 2 ] Run JOB 0 at PRIORITY 2 [ TICKS 7 ALLOT 1 TIME 81 (of 84) ]
      [ time 3 ] Run JOB 0 at PRIORITY 2 [ TICKS 6 ALLOT 1 TIME 80 (of 84) ]
      [ time 4 ] Run JOB 0 at PRIORITY 2 [ TICKS 5 ALLOT 1 TIME 79 (of 84) ]
      [ time 5 ] Run JOB 0 at PRIORITY 2 [ TICKS 4 ALLOT 1 TIME 78 (of 84) ]
      [ time 6 ] Run JOB 0 at PRIORITY 2 [ TICKS 3 ALLOT 1 TIME 77 (of 84) ]
      [ time 7 ] Run JOB 0 at PRIORITY 2 [ TICKS 2 ALLOT 1 TIME 76 (of 84) ]
      [ time 8 ] Run JOB 0 at PRIORITY 2 [ TICKS 1 ALLOT 1 TIME 75 (of 84) ]
      [ time 9 ] Run JOB 0 at PRIORITY 2 [ TICKS 0 ALLOT 1 TIME 74 (of 84) ]
      [ time 10 ] Run JOB 1 at PRIORITY 2 [ TICKS 9 ALLOT 1 TIME 41 (of 42) ]
      [ time 11 ] Run JOB 1 at PRIORITY 2 [ TICKS 8 ALLOT 1 TIME 40 (of 42) ]
      [ time 12 ] Run JOB 1 at PRIORITY 2 [ TICKS 7 ALLOT 1 TIME 39 (of 42) ]
      [ time 13 ] Run JOB 1 at PRIORITY 2 [ TICKS 6 ALLOT 1 TIME 38 (of 42) ]
      [ time 14 ] Run JOB 1 at PRIORITY 2 [ TICKS 5 ALLOT 1 TIME 37 (of 42) ]
      [ time 15 ] Run JOB 1 at PRIORITY 2 [ TICKS 4 ALLOT 1 TIME 36 (of 42) ]
      [ time 16 ] Run JOB 1 at PRIORITY 2 [ TICKS 3 ALLOT 1 TIME 35 (of 42) ]
      [ time 17 ] Run JOB 1 at PRIORITY 2 [ TICKS 2 ALLOT 1 TIME 34 (of 42) ]
      [ time 18 ] Run JOB 1 at PRIORITY 2 [ TICKS 1 ALLOT 1 TIME 33 (of 42) ]
      [ time 19 ] Run JOB 1 at PRIORITY 2 [ TICKS 0 ALLOT 1 TIME 32 (of 42) ]
      [ time 20 ] Run JOB 2 at PRIORITY 2 [ TICKS 9 ALLOT 1 TIME 50 (of 51) ]
      [ time 21 ] Run JOB 2 at PRIORITY 2 [ TICKS 8 ALLOT 1 TIME 49 (of 51) ]
      [ time 22 ] Run JOB 2 at PRIORITY 2 [ TICKS 7 ALLOT 1 TIME 48 (of 51) ]
      [ time 23 ] Run JOB 2 at PRIORITY 2 [ TICKS 6 ALLOT 1 TIME 47 (of 51) ]
      [ time 24 ] Run JOB 2 at PRIORITY 2 [ TICKS 5 ALLOT 1 TIME 46 (of 51) ]
      [ time 25 ] Run JOB 2 at PRIORITY 2 [ TICKS 4 ALLOT 1 TIME 45 (of 51) ]
      [ time 26 ] Run JOB 2 at PRIORITY 2 [ TICKS 3 ALLOT 1 TIME 44 (of 51) ]
      [ time 27 ] Run JOB 2 at PRIORITY 2 [ TICKS 2 ALLOT 1 TIME 43 (of 51) ]
      [ time 28 ] Run JOB 2 at PRIORITY 2 [ TICKS 1 ALLOT 1 TIME 42 (of 51) ]
      [ time 29 ] Run JOB 2 at PRIORITY 2 [ TICKS 0 ALLOT 1 TIME 41 (of 51) ]
      [ time 30 ] Run JOB 0 at PRIORITY 1 [ TICKS 9 ALLOT 1 TIME 73 (of 84) ]
      [ time 31 ] Run JOB 0 at PRIORITY 1 [ TICKS 8 ALLOT 1 TIME 72 (of 84) ]
      [ time 32 ] Run JOB 0 at PRIORITY 1 [ TICKS 7 ALLOT 1 TIME 71 (of 84) ]
      [ time 33 ] Run JOB 0 at PRIORITY 1 [ TICKS 6 ALLOT 1 TIME 70 (of 84) ]
      [ time 34 ] Run JOB 0 at PRIORITY 1 [ TICKS 5 ALLOT 1 TIME 69 (of 84) ]
      [ time 35 ] Run JOB 0 at PRIORITY 1 [ TICKS 4 ALLOT 1 TIME 68 (of 84) ]
      [ time 36 ] Run JOB 0 at PRIORITY 1 [ TICKS 3 ALLOT 1 TIME 67 (of 84) ]
      [ time 37 ] Run JOB 0 at PRIORITY 1 [ TICKS 2 ALLOT 1 TIME 66 (of 84) ]
      [ time 38 ] Run JOB 0 at PRIORITY 1 [ TICKS 1 ALLOT 1 TIME 65 (of 84) ]
      [ time 39 ] Run JOB 0 at PRIORITY 1 [ TICKS 0 ALLOT 1 TIME 64 (of 84) ]
      [ time 40 ] Run JOB 1 at PRIORITY 1 [ TICKS 9 ALLOT 1 TIME 31 (of 42) ]
      [ time 41 ] Run JOB 1 at PRIORITY 1 [ TICKS 8 ALLOT 1 TIME 30 (of 42) ]
      [ time 42 ] Run JOB 1 at PRIORITY 1 [ TICKS 7 ALLOT 1 TIME 29 (of 42) ]
      [ time 43 ] Run JOB 1 at PRIORITY 1 [ TICKS 6 ALLOT 1 TIME 28 (of 42) ]
      [ time 44 ] Run JOB 1 at PRIORITY 1 [ TICKS 5 ALLOT 1 TIME 27 (of 42) ]
      [ time 45 ] Run JOB 1 at PRIORITY 1 [ TICKS 4 ALLOT 1 TIME 26 (of 42) ]
      [ time 46 ] Run JOB 1 at PRIORITY 1 [ TICKS 3 ALLOT 1 TIME 25 (of 42) ]
      [ time 47 ] Run JOB 1 at PRIORITY 1 [ TICKS 2 ALLOT 1 TIME 24 (of 42) ]
      [ time 48 ] Run JOB 1 at PRIORITY 1 [ TICKS 1 ALLOT 1 TIME 23 (of 42) ]
      [ time 49 ] Run JOB 1 at PRIORITY 1 [ TICKS 0 ALLOT 1 TIME 22 (of 42) ]
      [ time 50 ] Run JOB 2 at PRIORITY 1 [ TICKS 9 ALLOT 1 TIME 40 (of 51) ]
      [ time 51 ] Run JOB 2 at PRIORITY 1 [ TICKS 8 ALLOT 1 TIME 39 (of 51) ]
      [ time 52 ] Run JOB 2 at PRIORITY 1 [ TICKS 7 ALLOT 1 TIME 38 (of 51) ]
      [ time 53 ] Run JOB 2 at PRIORITY 1 [ TICKS 6 ALLOT 1 TIME 37 (of 51) ]
      [ time 54 ] Run JOB 2 at PRIORITY 1 [ TICKS 5 ALLOT 1 TIME 36 (of 51) ]
      [ time 55 ] Run JOB 2 at PRIORITY 1 [ TICKS 4 ALLOT 1 TIME 35 (of 51) ]
      [ time 56 ] Run JOB 2 at PRIORITY 1 [ TICKS 3 ALLOT 1 TIME 34 (of 51) ]
      [ time 57 ] Run JOB 2 at PRIORITY 1 [ TICKS 2 ALLOT 1 TIME 33 (of 51) ]
      [ time 58 ] Run JOB 2 at PRIORITY 1 [ TICKS 1 ALLOT 1 TIME 32 (of 51) ]
      [ time 59 ] Run JOB 2 at PRIORITY 1 [ TICKS 0 ALLOT 1 TIME 31 (of 51) ]
      [ time 60 ] Run JOB 0 at PRIORITY 0 [ TICKS 9 ALLOT 1 TIME 63 (of 84) ]
      [ time 61 ] Run JOB 0 at PRIORITY 0 [ TICKS 8 ALLOT 1 TIME 62 (of 84) ]
      [ time 62 ] Run JOB 0 at PRIORITY 0 [ TICKS 7 ALLOT 1 TIME 61 (of 84) ]
      [ time 63 ] Run JOB 0 at PRIORITY 0 [ TICKS 6 ALLOT 1 TIME 60 (of 84) ]
      [ time 64 ] Run JOB 0 at PRIORITY 0 [ TICKS 5 ALLOT 1 TIME 59 (of 84) ]
      [ time 65 ] Run JOB 0 at PRIORITY 0 [ TICKS 4 ALLOT 1 TIME 58 (of 84) ]
      [ time 66 ] Run JOB 0 at PRIORITY 0 [ TICKS 3 ALLOT 1 TIME 57 (of 84) ]
      [ time 67 ] Run JOB 0 at PRIORITY 0 [ TICKS 2 ALLOT 1 TIME 56 (of 84) ]
      [ time 68 ] Run JOB 0 at PRIORITY 0 [ TICKS 1 ALLOT 1 TIME 55 (of 84) ]
      [ time 69 ] Run JOB 0 at PRIORITY 0 [ TICKS 0 ALLOT 1 TIME 54 (of 84) ]
      [ time 70 ] Run JOB 1 at PRIORITY 0 [ TICKS 9 ALLOT 1 TIME 21 (of 42) ]
      [ time 71 ] Run JOB 1 at PRIORITY 0 [ TICKS 8 ALLOT 1 TIME 20 (of 42) ]
      [ time 72 ] Run JOB 1 at PRIORITY 0 [ TICKS 7 ALLOT 1 TIME 19 (of 42) ]
      [ time 73 ] Run JOB 1 at PRIORITY 0 [ TICKS 6 ALLOT 1 TIME 18 (of 42) ]
      [ time 74 ] Run JOB 1 at PRIORITY 0 [ TICKS 5 ALLOT 1 TIME 17 (of 42) ]
      [ time 75 ] Run JOB 1 at PRIORITY 0 [ TICKS 4 ALLOT 1 TIME 16 (of 42) ]
      [ time 76 ] Run JOB 1 at PRIORITY 0 [ TICKS 3 ALLOT 1 TIME 15 (of 42) ]
      [ time 77 ] Run JOB 1 at PRIORITY 0 [ TICKS 2 ALLOT 1 TIME 14 (of 42) ]
      [ time 78 ] Run JOB 1 at PRIORITY 0 [ TICKS 1 ALLOT 1 TIME 13 (of 42) ]
      [ time 79 ] Run JOB 1 at PRIORITY 0 [ TICKS 0 ALLOT 1 TIME 12 (of 42) ]
      [ time 80 ] Run JOB 2 at PRIORITY 0 [ TICKS 9 ALLOT 1 TIME 30 (of 51) ]
      [ time 81 ] Run JOB 2 at PRIORITY 0 [ TICKS 8 ALLOT 1 TIME 29 (of 51) ]
      [ time 82 ] Run JOB 2 at PRIORITY 0 [ TICKS 7 ALLOT 1 TIME 28 (of 51) ]
      [ time 83 ] Run JOB 2 at PRIORITY 0 [ TICKS 6 ALLOT 1 TIME 27 (of 51) ]
      [ time 84 ] Run JOB 2 at PRIORITY 0 [ TICKS 5 ALLOT 1 TIME 26 (of 51) ]
      [ time 85 ] Run JOB 2 at PRIORITY 0 [ TICKS 4 ALLOT 1 TIME 25 (of 51) ]
      [ time 86 ] Run JOB 2 at PRIORITY 0 [ TICKS 3 ALLOT 1 TIME 24 (of 51) ]
      [ time 87 ] Run JOB 2 at PRIORITY 0 [ TICKS 2 ALLOT 1 TIME 23 (of 51) ]
      [ time 88 ] Run JOB 2 at PRIORITY 0 [ TICKS 1 ALLOT 1 TIME 22 (of 51) ]
      [ time 89 ] Run JOB 2 at PRIORITY 0 [ TICKS 0 ALLOT 1 TIME 21 (of 51) ]
      [ time 90 ] Run JOB 0 at PRIORITY 0 [ TICKS 9 ALLOT 1 TIME 53 (of 84) ]
      [ time 91 ] Run JOB 0 at PRIORITY 0 [ TICKS 8 ALLOT 1 TIME 52 (of 84) ]
      [ time 92 ] Run JOB 0 at PRIORITY 0 [ TICKS 7 ALLOT 1 TIME 51 (of 84) ]
      [ time 93 ] Run JOB 0 at PRIORITY 0 [ TICKS 6 ALLOT 1 TIME 50 (of 84) ]
      [ time 94 ] Run JOB 0 at PRIORITY 0 [ TICKS 5 ALLOT 1 TIME 49 (of 84) ]
      [ time 95 ] Run JOB 0 at PRIORITY 0 [ TICKS 4 ALLOT 1 TIME 48 (of 84) ]
      [ time 96 ] Run JOB 0 at PRIORITY 0 [ TICKS 3 ALLOT 1 TIME 47 (of 84) ]
      [ time 97 ] Run JOB 0 at PRIORITY 0 [ TICKS 2 ALLOT 1 TIME 46 (of 84) ]
      [ time 98 ] Run JOB 0 at PRIORITY 0 [ TICKS 1 ALLOT 1 TIME 45 (of 84) ]
      [ time 99 ] Run JOB 0 at PRIORITY 0 [ TICKS 0 ALLOT 1 TIME 44 (of 84) ]
      [ time 100 ] Run JOB 1 at PRIORITY 0 [ TICKS 9 ALLOT 1 TIME 11 (of 42) ]
      [ time 101 ] Run JOB 1 at PRIORITY 0 [ TICKS 8 ALLOT 1 TIME 10 (of 42) ]
      [ time 102 ] Run JOB 1 at PRIORITY 0 [ TICKS 7 ALLOT 1 TIME 9 (of 42) ]
      [ time 103 ] Run JOB 1 at PRIORITY 0 [ TICKS 6 ALLOT 1 TIME 8 (of 42) ]
      [ time 104 ] Run JOB 1 at PRIORITY 0 [ TICKS 5 ALLOT 1 TIME 7 (of 42) ]
      [ time 105 ] Run JOB 1 at PRIORITY 0 [ TICKS 4 ALLOT 1 TIME 6 (of 42) ]
      [ time 106 ] Run JOB 1 at PRIORITY 0 [ TICKS 3 ALLOT 1 TIME 5 (of 42) ]
      [ time 107 ] Run JOB 1 at PRIORITY 0 [ TICKS 2 ALLOT 1 TIME 4 (of 42) ]
      [ time 108 ] Run JOB 1 at PRIORITY 0 [ TICKS 1 ALLOT 1 TIME 3 (of 42) ]
      [ time 109 ] Run JOB 1 at PRIORITY 0 [ TICKS 0 ALLOT 1 TIME 2 (of 42) ]
      [ time 110 ] Run JOB 2 at PRIORITY 0 [ TICKS 9 ALLOT 1 TIME 20 (of 51) ]
      [ time 111 ] Run JOB 2 at PRIORITY 0 [ TICKS 8 ALLOT 1 TIME 19 (of 51) ]
      [ time 112 ] Run JOB 2 at PRIORITY 0 [ TICKS 7 ALLOT 1 TIME 18 (of 51) ]
      [ time 113 ] Run JOB 2 at PRIORITY 0 [ TICKS 6 ALLOT 1 TIME 17 (of 51) ]
      [ time 114 ] Run JOB 2 at PRIORITY 0 [ TICKS 5 ALLOT 1 TIME 16 (of 51) ]
      [ time 115 ] Run JOB 2 at PRIORITY 0 [ TICKS 4 ALLOT 1 TIME 15 (of 51) ]
      [ time 116 ] Run JOB 2 at PRIORITY 0 [ TICKS 3 ALLOT 1 TIME 14 (of 51) ]
      [ time 117 ] Run JOB 2 at PRIORITY 0 [ TICKS 2 ALLOT 1 TIME 13 (of 51) ]
      [ time 118 ] Run JOB 2 at PRIORITY 0 [ TICKS 1 ALLOT 1 TIME 12 (of 51) ]
      [ time 119 ] Run JOB 2 at PRIORITY 0 [ TICKS 0 ALLOT 1 TIME 11 (of 51) ]
      [ time 120 ] Run JOB 0 at PRIORITY 0 [ TICKS 9 ALLOT 1 TIME 43 (of 84) ]
      [ time 121 ] Run JOB 0 at PRIORITY 0 [ TICKS 8 ALLOT 1 TIME 42 (of 84) ]
      [ time 122 ] Run JOB 0 at PRIORITY 0 [ TICKS 7 ALLOT 1 TIME 41 (of 84) ]
      [ time 123 ] Run JOB 0 at PRIORITY 0 [ TICKS 6 ALLOT 1 TIME 40 (of 84) ]
      [ time 124 ] Run JOB 0 at PRIORITY 0 [ TICKS 5 ALLOT 1 TIME 39 (of 84) ]
      [ time 125 ] Run JOB 0 at PRIORITY 0 [ TICKS 4 ALLOT 1 TIME 38 (of 84) ]
      [ time 126 ] Run JOB 0 at PRIORITY 0 [ TICKS 3 ALLOT 1 TIME 37 (of 84) ]
      [ time 127 ] Run JOB 0 at PRIORITY 0 [ TICKS 2 ALLOT 1 TIME 36 (of 84) ]
      [ time 128 ] Run JOB 0 at PRIORITY 0 [ TICKS 1 ALLOT 1 TIME 35 (of 84) ]
      [ time 129 ] Run JOB 0 at PRIORITY 0 [ TICKS 0 ALLOT 1 TIME 34 (of 84) ]
      [ time 130 ] Run JOB 1 at PRIORITY 0 [ TICKS 9 ALLOT 1 TIME 1 (of 42) ]
      [ time 131 ] Run JOB 1 at PRIORITY 0 [ TICKS 8 ALLOT 1 TIME 0 (of 42) ]
      [ time 132 ] FINISHED JOB 1
      [ time 132 ] Run JOB 2 at PRIORITY 0 [ TICKS 9 ALLOT 1 TIME 10 (of 51) ]
      [ time 133 ] Run JOB 2 at PRIORITY 0 [ TICKS 8 ALLOT 1 TIME 9 (of 51) ]
      [ time 134 ] Run JOB 2 at PRIORITY 0 [ TICKS 7 ALLOT 1 TIME 8 (of 51) ]
      [ time 135 ] Run JOB 2 at PRIORITY 0 [ TICKS 6 ALLOT 1 TIME 7 (of 51) ]
      [ time 136 ] Run JOB 2 at PRIORITY 0 [ TICKS 5 ALLOT 1 TIME 6 (of 51) ]
      [ time 137 ] Run JOB 2 at PRIORITY 0 [ TICKS 4 ALLOT 1 TIME 5 (of 51) ]
      [ time 138 ] Run JOB 2 at PRIORITY 0 [ TICKS 3 ALLOT 1 TIME 4 (of 51) ]
      [ time 139 ] Run JOB 2 at PRIORITY 0 [ TICKS 2 ALLOT 1 TIME 3 (of 51) ]
      [ time 140 ] Run JOB 2 at PRIORITY 0 [ TICKS 1 ALLOT 1 TIME 2 (of 51) ]
      [ time 141 ] Run JOB 2 at PRIORITY 0 [ TICKS 0 ALLOT 1 TIME 1 (of 51) ]
      [ time 142 ] Run JOB 0 at PRIORITY 0 [ TICKS 9 ALLOT 1 TIME 33 (of 84) ]
      [ time 143 ] Run JOB 0 at PRIORITY 0 [ TICKS 8 ALLOT 1 TIME 32 (of 84) ]
      [ time 144 ] Run JOB 0 at PRIORITY 0 [ TICKS 7 ALLOT 1 TIME 31 (of 84) ]
      [ time 145 ] Run JOB 0 at PRIORITY 0 [ TICKS 6 ALLOT 1 TIME 30 (of 84) ]
      [ time 146 ] Run JOB 0 at PRIORITY 0 [ TICKS 5 ALLOT 1 TIME 29 (of 84) ]
      [ time 147 ] Run JOB 0 at PRIORITY 0 [ TICKS 4 ALLOT 1 TIME 28 (of 84) ]
      [ time 148 ] Run JOB 0 at PRIORITY 0 [ TICKS 3 ALLOT 1 TIME 27 (of 84) ]
      [ time 149 ] Run JOB 0 at PRIORITY 0 [ TICKS 2 ALLOT 1 TIME 26 (of 84) ]
      [ time 150 ] Run JOB 0 at PRIORITY 0 [ TICKS 1 ALLOT 1 TIME 25 (of 84) ]
      [ time 151 ] Run JOB 0 at PRIORITY 0 [ TICKS 0 ALLOT 1 TIME 24 (of 84) ]
      [ time 152 ] Run JOB 2 at PRIORITY 0 [ TICKS 9 ALLOT 1 TIME 0 (of 51) ]
      [ time 153 ] FINISHED JOB 2
      [ time 153 ] Run JOB 0 at PRIORITY 0 [ TICKS 9 ALLOT 1 TIME 23 (of 84) ]
      [ time 154 ] Run JOB 0 at PRIORITY 0 [ TICKS 8 ALLOT 1 TIME 22 (of 84) ]
      [ time 155 ] Run JOB 0 at PRIORITY 0 [ TICKS 7 ALLOT 1 TIME 21 (of 84) ]
      [ time 156 ] Run JOB 0 at PRIORITY 0 [ TICKS 6 ALLOT 1 TIME 20 (of 84) ]
      [ time 157 ] Run JOB 0 at PRIORITY 0 [ TICKS 5 ALLOT 1 TIME 19 (of 84) ]
      [ time 158 ] Run JOB 0 at PRIORITY 0 [ TICKS 4 ALLOT 1 TIME 18 (of 84) ]
      [ time 159 ] Run JOB 0 at PRIORITY 0 [ TICKS 3 ALLOT 1 TIME 17 (of 84) ]
      [ time 160 ] Run JOB 0 at PRIORITY 0 [ TICKS 2 ALLOT 1 TIME 16 (of 84) ]
      [ time 161 ] Run JOB 0 at PRIORITY 0 [ TICKS 1 ALLOT 1 TIME 15 (of 84) ]
      [ time 162 ] Run JOB 0 at PRIORITY 0 [ TICKS 0 ALLOT 1 TIME 14 (of 84) ]
      [ time 163 ] Run JOB 0 at PRIORITY 0 [ TICKS 9 ALLOT 1 TIME 13 (of 84) ]
      [ time 164 ] Run JOB 0 at PRIORITY 0 [ TICKS 8 ALLOT 1 TIME 12 (of 84) ]
      [ time 165 ] Run JOB 0 at PRIORITY 0 [ TICKS 7 ALLOT 1 TIME 11 (of 84) ]
      [ time 166 ] Run JOB 0 at PRIORITY 0 [ TICKS 6 ALLOT 1 TIME 10 (of 84) ]
      [ time 167 ] Run JOB 0 at PRIORITY 0 [ TICKS 5 ALLOT 1 TIME 9 (of 84) ]
      [ time 168 ] Run JOB 0 at PRIORITY 0 [ TICKS 4 ALLOT 1 TIME 8 (of 84) ]
      [ time 169 ] Run JOB 0 at PRIORITY 0 [ TICKS 3 ALLOT 1 TIME 7 (of 84) ]
      [ time 170 ] Run JOB 0 at PRIORITY 0 [ TICKS 2 ALLOT 1 TIME 6 (of 84) ]
      [ time 171 ] Run JOB 0 at PRIORITY 0 [ TICKS 1 ALLOT 1 TIME 5 (of 84) ]
      [ time 172 ] Run JOB 0 at PRIORITY 0 [ TICKS 0 ALLOT 1 TIME 4 (of 84) ]
      [ time 173 ] Run JOB 0 at PRIORITY 0 [ TICKS 9 ALLOT 1 TIME 3 (of 84) ]
      [ time 174 ] Run JOB 0 at PRIORITY 0 [ TICKS 8 ALLOT 1 TIME 2 (of 84) ]
      [ time 175 ] Run JOB 0 at PRIORITY 0 [ TICKS 7 ALLOT 1 TIME 1 (of 84) ]
      [ time 176 ] Run JOB 0 at PRIORITY 0 [ TICKS 6 ALLOT 1 TIME 0 (of 84) ]
      [ time 177 ] FINISHED JOB 0

      Final statistics:
        Job  0: startTime   0 - response   0 - turnaround 177
        Job  1: startTime   0 - response  10 - turnaround 132
        Job  2: startTime   0 - response  20 - turnaround 153

        Avg  2: startTime n/a - response 10.00 - turnaround 154.00
```
En este caso, primero se ejecutó el job 0 un ts de 10 ms y, como el time allotment era de 1, la prioridad del job 0 bajó, así fue sucediendo con cada job hasta que todos llegaron a la cola de menor prioridad y se quedaron ahi ya que no hay boost. El tiempo de ejecución fue igual al de round robin ya que no se consideró el I/O y el ts de cada cola era el mismo y todos los jobs una vez que se ejecutaban su time slice bajaban de prioridad por lo que ninguno se aprovechaba del scheduler.


2.2 Segundo escenario: Se utilizacon 3 colas, cada una con un time slice de 10ms y un time allotment de 1. Con I/O.
Se plantean dos situaciones, una con el flag -S en la cual permite resetear el time allotment y mantener a los jobs en la misma prioridad cuando se ejecuta una operación de I/O y otra sin ese flag.

a) sin flags -S
``` console
./mlfq.py -c  -n 3 - q 10 -a 1 -B 0 -l 0,40,4:0,25,0:0,12,0

Here is the list of inputs:
OPTIONS jobs 3
OPTIONS queues 3
OPTIONS allotments for queue  2 is   1
OPTIONS quantum length for queue  2 is  10
OPTIONS allotments for queue  1 is   1
OPTIONS quantum length for queue  1 is  10
OPTIONS allotments for queue  0 is   1
OPTIONS quantum length for queue  0 is  10
OPTIONS boost 0
OPTIONS ioTime 5
OPTIONS stayAfterIO False
OPTIONS iobump False


For each job, three defining characteristics are given:
  startTime : at what time does the job enter the system
  runTime   : the total CPU time needed by the job to finish
  ioFreq    : every ioFreq time units, the job issues an I/O
              (the I/O takes ioTime units to complete)

Job List:
  Job  0: startTime   0 - runTime  40 - ioFreq   4
  Job  1: startTime   0 - runTime  25 - ioFreq   0
  Job  2: startTime   0 - runTime  12 - ioFreq   0


Execution Trace:

[ time 0 ] JOB BEGINS by JOB 0
[ time 0 ] JOB BEGINS by JOB 1
[ time 0 ] JOB BEGINS by JOB 2
[ time 0 ] Run JOB 0 at PRIORITY 2 [ TICKS 9 ALLOT 1 TIME 39 (of 40) ]
[ time 1 ] Run JOB 0 at PRIORITY 2 [ TICKS 8 ALLOT 1 TIME 38 (of 40) ]
[ time 2 ] Run JOB 0 at PRIORITY 2 [ TICKS 7 ALLOT 1 TIME 37 (of 40) ]
[ time 3 ] Run JOB 0 at PRIORITY 2 [ TICKS 6 ALLOT 1 TIME 36 (of 40) ]
[ time 4 ] IO_START by JOB 0
IO DONE
[ time 4 ] Run JOB 1 at PRIORITY 2 [ TICKS 9 ALLOT 1 TIME 24 (of 25) ]
[ time 5 ] Run JOB 1 at PRIORITY 2 [ TICKS 8 ALLOT 1 TIME 23 (of 25) ]
[ time 6 ] Run JOB 1 at PRIORITY 2 [ TICKS 7 ALLOT 1 TIME 22 (of 25) ]
[ time 7 ] Run JOB 1 at PRIORITY 2 [ TICKS 6 ALLOT 1 TIME 21 (of 25) ]
[ time 8 ] Run JOB 1 at PRIORITY 2 [ TICKS 5 ALLOT 1 TIME 20 (of 25) ]
[ time 9 ] IO_DONE by JOB 0
[ time 9 ] Run JOB 1 at PRIORITY 2 [ TICKS 4 ALLOT 1 TIME 19 (of 25) ]
[ time 10 ] Run JOB 1 at PRIORITY 2 [ TICKS 3 ALLOT 1 TIME 18 (of 25) ]
[ time 11 ] Run JOB 1 at PRIORITY 2 [ TICKS 2 ALLOT 1 TIME 17 (of 25) ]
[ time 12 ] Run JOB 1 at PRIORITY 2 [ TICKS 1 ALLOT 1 TIME 16 (of 25) ]
[ time 13 ] Run JOB 1 at PRIORITY 2 [ TICKS 0 ALLOT 1 TIME 15 (of 25) ]
[ time 14 ] Run JOB 2 at PRIORITY 2 [ TICKS 9 ALLOT 1 TIME 11 (of 12) ]
[ time 15 ] Run JOB 2 at PRIORITY 2 [ TICKS 8 ALLOT 1 TIME 10 (of 12) ]
[ time 16 ] Run JOB 2 at PRIORITY 2 [ TICKS 7 ALLOT 1 TIME 9 (of 12) ]
[ time 17 ] Run JOB 2 at PRIORITY 2 [ TICKS 6 ALLOT 1 TIME 8 (of 12) ]
[ time 18 ] Run JOB 2 at PRIORITY 2 [ TICKS 5 ALLOT 1 TIME 7 (of 12) ]
[ time 19 ] Run JOB 2 at PRIORITY 2 [ TICKS 4 ALLOT 1 TIME 6 (of 12) ]
[ time 20 ] Run JOB 2 at PRIORITY 2 [ TICKS 3 ALLOT 1 TIME 5 (of 12) ]
[ time 21 ] Run JOB 2 at PRIORITY 2 [ TICKS 2 ALLOT 1 TIME 4 (of 12) ]
[ time 22 ] Run JOB 2 at PRIORITY 2 [ TICKS 1 ALLOT 1 TIME 3 (of 12) ]
[ time 23 ] Run JOB 2 at PRIORITY 2 [ TICKS 0 ALLOT 1 TIME 2 (of 12) ]
[ time 24 ] Run JOB 0 at PRIORITY 2 [ TICKS 5 ALLOT 1 TIME 35 (of 40) ]
[ time 25 ] Run JOB 0 at PRIORITY 2 [ TICKS 4 ALLOT 1 TIME 34 (of 40) ]
[ time 26 ] Run JOB 0 at PRIORITY 2 [ TICKS 3 ALLOT 1 TIME 33 (of 40) ]
[ time 27 ] Run JOB 0 at PRIORITY 2 [ TICKS 2 ALLOT 1 TIME 32 (of 40) ]
[ time 28 ] IO_START by JOB 0
IO DONE
[ time 28 ] Run JOB 1 at PRIORITY 1 [ TICKS 9 ALLOT 1 TIME 14 (of 25) ]
[ time 29 ] Run JOB 1 at PRIORITY 1 [ TICKS 8 ALLOT 1 TIME 13 (of 25) ]
[ time 30 ] Run JOB 1 at PRIORITY 1 [ TICKS 7 ALLOT 1 TIME 12 (of 25) ]
[ time 31 ] Run JOB 1 at PRIORITY 1 [ TICKS 6 ALLOT 1 TIME 11 (of 25) ]
[ time 32 ] Run JOB 1 at PRIORITY 1 [ TICKS 5 ALLOT 1 TIME 10 (of 25) ]
[ time 33 ] IO_DONE by JOB 0
[ time 33 ] Run JOB 0 at PRIORITY 2 [ TICKS 1 ALLOT 1 TIME 31 (of 40) ]
[ time 34 ] Run JOB 0 at PRIORITY 2 [ TICKS 0 ALLOT 1 TIME 30 (of 40) ]
[ time 35 ] Run JOB 1 at PRIORITY 1 [ TICKS 4 ALLOT 1 TIME 9 (of 25) ]
[ time 36 ] Run JOB 1 at PRIORITY 1 [ TICKS 3 ALLOT 1 TIME 8 (of 25) ]
[ time 37 ] Run JOB 1 at PRIORITY 1 [ TICKS 2 ALLOT 1 TIME 7 (of 25) ]
[ time 38 ] Run JOB 1 at PRIORITY 1 [ TICKS 1 ALLOT 1 TIME 6 (of 25) ]
[ time 39 ] Run JOB 1 at PRIORITY 1 [ TICKS 0 ALLOT 1 TIME 5 (of 25) ]
[ time 40 ] Run JOB 2 at PRIORITY 1 [ TICKS 9 ALLOT 1 TIME 1 (of 12) ]
[ time 41 ] Run JOB 2 at PRIORITY 1 [ TICKS 8 ALLOT 1 TIME 0 (of 12) ]
[ time 42 ] FINISHED JOB 2
[ time 42 ] Run JOB 0 at PRIORITY 1 [ TICKS 9 ALLOT 1 TIME 29 (of 40) ]
[ time 43 ] Run JOB 0 at PRIORITY 1 [ TICKS 8 ALLOT 1 TIME 28 (of 40) ]
[ time 44 ] IO_START by JOB 0
IO DONE
[ time 44 ] Run JOB 1 at PRIORITY 0 [ TICKS 9 ALLOT 1 TIME 4 (of 25) ]
[ time 45 ] Run JOB 1 at PRIORITY 0 [ TICKS 8 ALLOT 1 TIME 3 (of 25) ]
[ time 46 ] Run JOB 1 at PRIORITY 0 [ TICKS 7 ALLOT 1 TIME 2 (of 25) ]
[ time 47 ] Run JOB 1 at PRIORITY 0 [ TICKS 6 ALLOT 1 TIME 1 (of 25) ]
[ time 48 ] Run JOB 1 at PRIORITY 0 [ TICKS 5 ALLOT 1 TIME 0 (of 25) ]
[ time 49 ] FINISHED JOB 1
[ time 49 ] IO_DONE by JOB 0
[ time 49 ] Run JOB 0 at PRIORITY 1 [ TICKS 7 ALLOT 1 TIME 27 (of 40) ]
[ time 50 ] Run JOB 0 at PRIORITY 1 [ TICKS 6 ALLOT 1 TIME 26 (of 40) ]
[ time 51 ] Run JOB 0 at PRIORITY 1 [ TICKS 5 ALLOT 1 TIME 25 (of 40) ]
[ time 52 ] Run JOB 0 at PRIORITY 1 [ TICKS 4 ALLOT 1 TIME 24 (of 40) ]
[ time 53 ] IO_START by JOB 0
IO DONE
[ time 53 ] IDLE
[ time 54 ] IDLE
[ time 55 ] IDLE
[ time 56 ] IDLE
[ time 57 ] IDLE
[ time 58 ] IO_DONE by JOB 0
[ time 58 ] Run JOB 0 at PRIORITY 1 [ TICKS 3 ALLOT 1 TIME 23 (of 40) ]
[ time 59 ] Run JOB 0 at PRIORITY 1 [ TICKS 2 ALLOT 1 TIME 22 (of 40) ]
[ time 60 ] Run JOB 0 at PRIORITY 1 [ TICKS 1 ALLOT 1 TIME 21 (of 40) ]
[ time 61 ] Run JOB 0 at PRIORITY 1 [ TICKS 0 ALLOT 1 TIME 20 (of 40) ]
[ time 62 ] IO_START by JOB 0
IO DONE
[ time 62 ] IDLE
[ time 63 ] IDLE
[ time 64 ] IDLE
[ time 65 ] IDLE
[ time 66 ] IDLE
[ time 67 ] IO_DONE by JOB 0
[ time 67 ] Run JOB 0 at PRIORITY 0 [ TICKS 9 ALLOT 1 TIME 19 (of 40) ]
[ time 68 ] Run JOB 0 at PRIORITY 0 [ TICKS 8 ALLOT 1 TIME 18 (of 40) ]
[ time 69 ] Run JOB 0 at PRIORITY 0 [ TICKS 7 ALLOT 1 TIME 17 (of 40) ]
[ time 70 ] Run JOB 0 at PRIORITY 0 [ TICKS 6 ALLOT 1 TIME 16 (of 40) ]
[ time 71 ] IO_START by JOB 0
IO DONE
[ time 71 ] IDLE
[ time 72 ] IDLE
[ time 73 ] IDLE
[ time 74 ] IDLE
[ time 75 ] IDLE
[ time 76 ] IO_DONE by JOB 0
[ time 76 ] Run JOB 0 at PRIORITY 0 [ TICKS 5 ALLOT 1 TIME 15 (of 40) ]
[ time 77 ] Run JOB 0 at PRIORITY 0 [ TICKS 4 ALLOT 1 TIME 14 (of 40) ]
[ time 78 ] Run JOB 0 at PRIORITY 0 [ TICKS 3 ALLOT 1 TIME 13 (of 40) ]
[ time 79 ] Run JOB 0 at PRIORITY 0 [ TICKS 2 ALLOT 1 TIME 12 (of 40) ]
[ time 80 ] IO_START by JOB 0
IO DONE
[ time 80 ] IDLE
[ time 81 ] IDLE
[ time 82 ] IDLE
[ time 83 ] IDLE
[ time 84 ] IDLE
[ time 85 ] IO_DONE by JOB 0
[ time 85 ] Run JOB 0 at PRIORITY 0 [ TICKS 1 ALLOT 1 TIME 11 (of 40) ]
[ time 86 ] Run JOB 0 at PRIORITY 0 [ TICKS 0 ALLOT 1 TIME 10 (of 40) ]
[ time 87 ] Run JOB 0 at PRIORITY 0 [ TICKS 9 ALLOT 1 TIME 9 (of 40) ]
[ time 88 ] Run JOB 0 at PRIORITY 0 [ TICKS 8 ALLOT 1 TIME 8 (of 40) ]
[ time 89 ] IO_START by JOB 0
IO DONE
[ time 89 ] IDLE
[ time 90 ] IDLE
[ time 91 ] IDLE
[ time 92 ] IDLE
[ time 93 ] IDLE
[ time 94 ] IO_DONE by JOB 0
[ time 94 ] Run JOB 0 at PRIORITY 0 [ TICKS 7 ALLOT 1 TIME 7 (of 40) ]
[ time 95 ] Run JOB 0 at PRIORITY 0 [ TICKS 6 ALLOT 1 TIME 6 (of 40) ]
[ time 96 ] Run JOB 0 at PRIORITY 0 [ TICKS 5 ALLOT 1 TIME 5 (of 40) ]
[ time 97 ] Run JOB 0 at PRIORITY 0 [ TICKS 4 ALLOT 1 TIME 4 (of 40) ]
[ time 98 ] IO_START by JOB 0
IO DONE
[ time 98 ] IDLE
[ time 99 ] IDLE
[ time 100 ] IDLE
[ time 101 ] IDLE
[ time 102 ] IDLE
[ time 103 ] IO_DONE by JOB 0
[ time 103 ] Run JOB 0 at PRIORITY 0 [ TICKS 3 ALLOT 1 TIME 3 (of 40) ]
[ time 104 ] Run JOB 0 at PRIORITY 0 [ TICKS 2 ALLOT 1 TIME 2 (of 40) ]
[ time 105 ] Run JOB 0 at PRIORITY 0 [ TICKS 1 ALLOT 1 TIME 1 (of 40) ]
[ time 106 ] Run JOB 0 at PRIORITY 0 [ TICKS 0 ALLOT 1 TIME 0 (of 40) ]
[ time 107 ] FINISHED JOB 0

Final statistics:
  Job  0: startTime   0 - response   0 - turnaround 107
  Job  1: startTime   0 - response   4 - turnaround  49
  Job  2: startTime   0 - response  14 - turnaround  42

  Avg  2: startTime n/a - response 6.00 - turnaround 66.00
```
En este caso se corrieron los 3 jobs a un time arrival de 0. El job 0 tiene un runtime de 40 y realiza I/O
con una frecuencia de 4 mientras que los otros jobs no realizan I/0 y sus runtime para el job 1 es de 25 ms y para el job 2 es de 12.
Vemos como el job 0 es el que mas tarda en terminar su ejecucion y al no aplicarle el flag -S este baja de prioridad al pasar un time allotment.  

b) Con flag -S :
``` console
./mlfq.py -c  -n 3 - q 10 -a 1 -B 0 -l 0,40,4:0,25,0:0,12,0 -S

Here is the list of inputs:
OPTIONS jobs 3
OPTIONS queues 3
OPTIONS allotments for queue  2 is   1
OPTIONS quantum length for queue  2 is  10
OPTIONS allotments for queue  1 is   1
OPTIONS quantum length for queue  1 is  10
OPTIONS allotments for queue  0 is   1
OPTIONS quantum length for queue  0 is  10
OPTIONS boost 0
OPTIONS ioTime 5
OPTIONS stayAfterIO True
OPTIONS iobump False


For each job, three defining characteristics are given:
  startTime : at what time does the job enter the system
  runTime   : the total CPU time needed by the job to finish
  ioFreq    : every ioFreq time units, the job issues an I/O
              (the I/O takes ioTime units to complete)

Job List:
  Job  0: startTime   0 - runTime  40 - ioFreq   4
  Job  1: startTime   0 - runTime  25 - ioFreq   0
  Job  2: startTime   0 - runTime  12 - ioFreq   0


Execution Trace:

[ time 0 ] JOB BEGINS by JOB 0
[ time 0 ] JOB BEGINS by JOB 1
[ time 0 ] JOB BEGINS by JOB 2
[ time 0 ] Run JOB 0 at PRIORITY 2 [ TICKS 9 ALLOT 1 TIME 39 (of 40) ]
[ time 1 ] Run JOB 0 at PRIORITY 2 [ TICKS 8 ALLOT 1 TIME 38 (of 40) ]
[ time 2 ] Run JOB 0 at PRIORITY 2 [ TICKS 7 ALLOT 1 TIME 37 (of 40) ]
[ time 3 ] Run JOB 0 at PRIORITY 2 [ TICKS 6 ALLOT 1 TIME 36 (of 40) ]
[ time 4 ] IO_START by JOB 0
IO DONE
[ time 4 ] Run JOB 1 at PRIORITY 2 [ TICKS 9 ALLOT 1 TIME 24 (of 25) ]
[ time 5 ] Run JOB 1 at PRIORITY 2 [ TICKS 8 ALLOT 1 TIME 23 (of 25) ]
[ time 6 ] Run JOB 1 at PRIORITY 2 [ TICKS 7 ALLOT 1 TIME 22 (of 25) ]
[ time 7 ] Run JOB 1 at PRIORITY 2 [ TICKS 6 ALLOT 1 TIME 21 (of 25) ]
[ time 8 ] Run JOB 1 at PRIORITY 2 [ TICKS 5 ALLOT 1 TIME 20 (of 25) ]
[ time 9 ] IO_DONE by JOB 0
[ time 9 ] Run JOB 1 at PRIORITY 2 [ TICKS 4 ALLOT 1 TIME 19 (of 25) ]
[ time 10 ] Run JOB 1 at PRIORITY 2 [ TICKS 3 ALLOT 1 TIME 18 (of 25) ]
[ time 11 ] Run JOB 1 at PRIORITY 2 [ TICKS 2 ALLOT 1 TIME 17 (of 25) ]
[ time 12 ] Run JOB 1 at PRIORITY 2 [ TICKS 1 ALLOT 1 TIME 16 (of 25) ]
[ time 13 ] Run JOB 1 at PRIORITY 2 [ TICKS 0 ALLOT 1 TIME 15 (of 25) ]
[ time 14 ] Run JOB 2 at PRIORITY 2 [ TICKS 9 ALLOT 1 TIME 11 (of 12) ]
[ time 15 ] Run JOB 2 at PRIORITY 2 [ TICKS 8 ALLOT 1 TIME 10 (of 12) ]
[ time 16 ] Run JOB 2 at PRIORITY 2 [ TICKS 7 ALLOT 1 TIME 9 (of 12) ]
[ time 17 ] Run JOB 2 at PRIORITY 2 [ TICKS 6 ALLOT 1 TIME 8 (of 12) ]
[ time 18 ] Run JOB 2 at PRIORITY 2 [ TICKS 5 ALLOT 1 TIME 7 (of 12) ]
[ time 19 ] Run JOB 2 at PRIORITY 2 [ TICKS 4 ALLOT 1 TIME 6 (of 12) ]
[ time 20 ] Run JOB 2 at PRIORITY 2 [ TICKS 3 ALLOT 1 TIME 5 (of 12) ]
[ time 21 ] Run JOB 2 at PRIORITY 2 [ TICKS 2 ALLOT 1 TIME 4 (of 12) ]
[ time 22 ] Run JOB 2 at PRIORITY 2 [ TICKS 1 ALLOT 1 TIME 3 (of 12) ]
[ time 23 ] Run JOB 2 at PRIORITY 2 [ TICKS 0 ALLOT 1 TIME 2 (of 12) ]
[ time 24 ] Run JOB 0 at PRIORITY 2 [ TICKS 9 ALLOT 1 TIME 35 (of 40) ]
[ time 25 ] Run JOB 0 at PRIORITY 2 [ TICKS 8 ALLOT 1 TIME 34 (of 40) ]
[ time 26 ] Run JOB 0 at PRIORITY 2 [ TICKS 7 ALLOT 1 TIME 33 (of 40) ]
[ time 27 ] Run JOB 0 at PRIORITY 2 [ TICKS 6 ALLOT 1 TIME 32 (of 40) ]
[ time 28 ] IO_START by JOB 0
IO DONE
[ time 28 ] Run JOB 1 at PRIORITY 1 [ TICKS 9 ALLOT 1 TIME 14 (of 25) ]
[ time 29 ] Run JOB 1 at PRIORITY 1 [ TICKS 8 ALLOT 1 TIME 13 (of 25) ]
[ time 30 ] Run JOB 1 at PRIORITY 1 [ TICKS 7 ALLOT 1 TIME 12 (of 25) ]
[ time 31 ] Run JOB 1 at PRIORITY 1 [ TICKS 6 ALLOT 1 TIME 11 (of 25) ]
[ time 32 ] Run JOB 1 at PRIORITY 1 [ TICKS 5 ALLOT 1 TIME 10 (of 25) ]
[ time 33 ] IO_DONE by JOB 0
[ time 33 ] Run JOB 0 at PRIORITY 2 [ TICKS 9 ALLOT 1 TIME 31 (of 40) ]
[ time 34 ] Run JOB 0 at PRIORITY 2 [ TICKS 8 ALLOT 1 TIME 30 (of 40) ]
[ time 35 ] Run JOB 0 at PRIORITY 2 [ TICKS 7 ALLOT 1 TIME 29 (of 40) ]
[ time 36 ] Run JOB 0 at PRIORITY 2 [ TICKS 6 ALLOT 1 TIME 28 (of 40) ]
[ time 37 ] IO_START by JOB 0
IO DONE
[ time 37 ] Run JOB 1 at PRIORITY 1 [ TICKS 4 ALLOT 1 TIME 9 (of 25) ]
[ time 38 ] Run JOB 1 at PRIORITY 1 [ TICKS 3 ALLOT 1 TIME 8 (of 25) ]
[ time 39 ] Run JOB 1 at PRIORITY 1 [ TICKS 2 ALLOT 1 TIME 7 (of 25) ]
[ time 40 ] Run JOB 1 at PRIORITY 1 [ TICKS 1 ALLOT 1 TIME 6 (of 25) ]
[ time 41 ] Run JOB 1 at PRIORITY 1 [ TICKS 0 ALLOT 1 TIME 5 (of 25) ]
[ time 42 ] IO_DONE by JOB 0
[ time 42 ] Run JOB 0 at PRIORITY 2 [ TICKS 9 ALLOT 1 TIME 27 (of 40) ]
[ time 43 ] Run JOB 0 at PRIORITY 2 [ TICKS 8 ALLOT 1 TIME 26 (of 40) ]
[ time 44 ] Run JOB 0 at PRIORITY 2 [ TICKS 7 ALLOT 1 TIME 25 (of 40) ]
[ time 45 ] Run JOB 0 at PRIORITY 2 [ TICKS 6 ALLOT 1 TIME 24 (of 40) ]
[ time 46 ] IO_START by JOB 0
IO DONE
[ time 46 ] Run JOB 2 at PRIORITY 1 [ TICKS 9 ALLOT 1 TIME 1 (of 12) ]
[ time 47 ] Run JOB 2 at PRIORITY 1 [ TICKS 8 ALLOT 1 TIME 0 (of 12) ]
[ time 48 ] FINISHED JOB 2
[ time 48 ] Run JOB 1 at PRIORITY 0 [ TICKS 9 ALLOT 1 TIME 4 (of 25) ]
[ time 49 ] Run JOB 1 at PRIORITY 0 [ TICKS 8 ALLOT 1 TIME 3 (of 25) ]
[ time 50 ] Run JOB 1 at PRIORITY 0 [ TICKS 7 ALLOT 1 TIME 2 (of 25) ]
[ time 51 ] IO_DONE by JOB 0
[ time 51 ] Run JOB 0 at PRIORITY 2 [ TICKS 9 ALLOT 1 TIME 23 (of 40) ]
[ time 52 ] Run JOB 0 at PRIORITY 2 [ TICKS 8 ALLOT 1 TIME 22 (of 40) ]
[ time 53 ] Run JOB 0 at PRIORITY 2 [ TICKS 7 ALLOT 1 TIME 21 (of 40) ]
[ time 54 ] Run JOB 0 at PRIORITY 2 [ TICKS 6 ALLOT 1 TIME 20 (of 40) ]
[ time 55 ] IO_START by JOB 0
IO DONE
[ time 55 ] Run JOB 1 at PRIORITY 0 [ TICKS 6 ALLOT 1 TIME 1 (of 25) ]
[ time 56 ] Run JOB 1 at PRIORITY 0 [ TICKS 5 ALLOT 1 TIME 0 (of 25) ]
[ time 57 ] FINISHED JOB 1
[ time 57 ] IDLE
[ time 58 ] IDLE
[ time 59 ] IDLE
[ time 60 ] IO_DONE by JOB 0
[ time 60 ] Run JOB 0 at PRIORITY 2 [ TICKS 9 ALLOT 1 TIME 19 (of 40) ]
[ time 61 ] Run JOB 0 at PRIORITY 2 [ TICKS 8 ALLOT 1 TIME 18 (of 40) ]
[ time 62 ] Run JOB 0 at PRIORITY 2 [ TICKS 7 ALLOT 1 TIME 17 (of 40) ]
[ time 63 ] Run JOB 0 at PRIORITY 2 [ TICKS 6 ALLOT 1 TIME 16 (of 40) ]
[ time 64 ] IO_START by JOB 0
IO DONE
[ time 64 ] IDLE
[ time 65 ] IDLE
[ time 66 ] IDLE
[ time 67 ] IDLE
[ time 68 ] IDLE
[ time 69 ] IO_DONE by JOB 0
[ time 69 ] Run JOB 0 at PRIORITY 2 [ TICKS 9 ALLOT 1 TIME 15 (of 40) ]
[ time 70 ] Run JOB 0 at PRIORITY 2 [ TICKS 8 ALLOT 1 TIME 14 (of 40) ]
[ time 71 ] Run JOB 0 at PRIORITY 2 [ TICKS 7 ALLOT 1 TIME 13 (of 40) ]
[ time 72 ] Run JOB 0 at PRIORITY 2 [ TICKS 6 ALLOT 1 TIME 12 (of 40) ]
[ time 73 ] IO_START by JOB 0
IO DONE
[ time 73 ] IDLE
[ time 74 ] IDLE
[ time 75 ] IDLE
[ time 76 ] IDLE
[ time 77 ] IDLE
[ time 78 ] IO_DONE by JOB 0
[ time 78 ] Run JOB 0 at PRIORITY 2 [ TICKS 9 ALLOT 1 TIME 11 (of 40) ]
[ time 79 ] Run JOB 0 at PRIORITY 2 [ TICKS 8 ALLOT 1 TIME 10 (of 40) ]
[ time 80 ] Run JOB 0 at PRIORITY 2 [ TICKS 7 ALLOT 1 TIME 9 (of 40) ]
[ time 81 ] Run JOB 0 at PRIORITY 2 [ TICKS 6 ALLOT 1 TIME 8 (of 40) ]
[ time 82 ] IO_START by JOB 0
IO DONE
[ time 82 ] IDLE
[ time 83 ] IDLE
[ time 84 ] IDLE
[ time 85 ] IDLE
[ time 86 ] IDLE
[ time 87 ] IO_DONE by JOB 0
[ time 87 ] Run JOB 0 at PRIORITY 2 [ TICKS 9 ALLOT 1 TIME 7 (of 40) ]
[ time 88 ] Run JOB 0 at PRIORITY 2 [ TICKS 8 ALLOT 1 TIME 6 (of 40) ]
[ time 89 ] Run JOB 0 at PRIORITY 2 [ TICKS 7 ALLOT 1 TIME 5 (of 40) ]
[ time 90 ] Run JOB 0 at PRIORITY 2 [ TICKS 6 ALLOT 1 TIME 4 (of 40) ]
[ time 91 ] IO_START by JOB 0
IO DONE
[ time 91 ] IDLE
[ time 92 ] IDLE
[ time 93 ] IDLE
[ time 94 ] IDLE
[ time 95 ] IDLE
[ time 96 ] IO_DONE by JOB 0
[ time 96 ] Run JOB 0 at PRIORITY 2 [ TICKS 9 ALLOT 1 TIME 3 (of 40) ]
[ time 97 ] Run JOB 0 at PRIORITY 2 [ TICKS 8 ALLOT 1 TIME 2 (of 40) ]
[ time 98 ] Run JOB 0 at PRIORITY 2 [ TICKS 7 ALLOT 1 TIME 1 (of 40) ]
[ time 99 ] Run JOB 0 at PRIORITY 2 [ TICKS 6 ALLOT 1 TIME 0 (of 40) ]
[ time 100 ] FINISHED JOB 0

Final statistics:
  Job  0: startTime   0 - response   0 - turnaround 100
  Job  1: startTime   0 - response   4 - turnaround  57
  Job  2: startTime   0 - response  14 - turnaround  48

  Avg  2: startTime n/a - response 6.00 - turnaround 68.33

Tiempos de finalizacion de los procesos:
Job0 t: 100 ms
JOB1 t: 57 ms
Job2 t: 48 ms
```

En este caso podemos ver como el job 0 que es el que realiza I/O siempre se mantiene en la prioridad superior, mientras que los otros jobs como no realizan I/O estos bajan de prioridad.

> Indicar claramente cuándo (en qué unidad de tiempo) termina cada uno de los jobs y si se pudo o no “engañar” al scheduler para monopolizar el CPU.

En este caso como el proceso 0 siempre se mantiene en la misma prioridad, a la hora de elegir que
proceso correr siempre se va a elegir al proceso 0 sobre los otros procesos ya que los otros, una vez que se ejecuten un ts y pase un time allotment, van a bajar de prioridad por lo que por como es el algoritmo estos va a correr solo cuando el job 0 esté realizando I/O, y una vez que el job 0 termine de realizar el I/0 y se haya terminado el ts de otro proceso en ejecución, mflq va a elegir al job 0 por tener siempre una mejor prioridad.

Es por esto que se engaña de alguna manera al scheduler.

Si se tuviera distintos time slice entre las colas donde el mayor ts estuviera en la cola de mayor prioridad, los procesos que realicen I/0 se aprovecharían más de scheduler ya que los otros bajan de prioridad y no pueden volver a subir debido a que no hay un boost.

En el caso de la corrida sin `-S` no hay engaño ya que justamente no se resetea el time allotment por lo que van bajando de prioridad, a su vez el ts de cada cola es el mismo por lo que no fueron afectados los tiempos al tener I/O sin flags `-S` con respecto a no tener I/O.


# Implementación

Para nuestra implementación de scheduler con prioridades nos basamos en el "lottery scheduler" que se presenta en el capitulo 9 del OSTEP. Nuestra implemetación consiste en otorgarle prioridades a cada proceso.

Estos procesos por primera vez son otorgados al primer proceso en `env_create()` y en `env_alloc()` con una prioridad fija para todos (NENV/4).

Para determinar que proceso se va a ejecutar se define un ganador que es un numero entre 0 y la suma de todas las prioridades de los procesos y un contador que va llevar la cuenta de las prioridades de cada proceso runnable y el proceso running.

Se itera por el vector de procesos como se hacia con el scheduler sin prioridades (round robin) y se va actualizando el contador con las prioridades de cada proceso runnable y el proceso running
(contador = contador + prioridad del proceso).

Para determinar que proceso correr se compara el contador contra el winner, si el contador es mayor o igual que el winner se ejecuta ese proceso, sino se prueba con otro y así hasta que no haya mas procesos.
En el caso en que no haya procesos para correr se ejecuta el proceso current si es que hay uno corriendo.

#### Asignacion de prioridades

Para la asignacion de prioridades a los procesos tuvimos encuenta lo que mencionaba el capitulo 9 del OSTEP en la cual menciona que uno de los problemas que tiene el lottery scheduling es que no hay una forma determinada para asignar prioridades, el libro sugiere que el usuario es el que mejor sabe de que forma deberia asignar las prioridades.
Como primera instancia para asignar la prioridad a los procesos, como no existe tal usuario mencionado en OSTEP lo que planteamos fue asignar las prioridades de forma semi aleatoria.
Para el caso donde el padre le asigna la prioridad a los hijos acotabamos la aleatoriad a un rango entre 0 y la prioridad del padre - 1 y en el caso de cuando se le asignaba en env_alloc() se verificaba que la prioridad sea un valor mayor a la minima(NENS/4). El problema que trae esto es que no hay alguien que decide quien es mas o menos importante sino que justamente es aleatorio(no hay forma de garantizar que el proceso que es prioritario vaya a tener una prioridad alta), por lo que no es predecible ni deterministico. Como solucion a este problema decimos otorgar un valor fijo de prioridades.
Finalmente, la asignacion de priopridades que tuvimos en cuenta fue esta: en Env_alloc() le asignamos como prioridad fija el valor de NENV/4 ya que es un valor ni muy grande ni muy pequeño, en este caso como todos tiene la misma prioridad, tienen la misma probabilidad de ejecutarse, su ejecucion esta determinada por la parte no deterministica del algoritmo(el calculo del winner y la posicion en el vector de los enviroment).
En fork cuando el padre le asigna la prioridad a sus hijos, esta es dos tercios de la prioridad del padre (un valor fijo). Es un valor lo suficientemente alto como para que pueda ejecutarse y a su vez es menor que la del padre para que este no pueda aprovecharse del scheduler por medio de sus hijos.

##### Las funciones que se modificaron fueron:

 * `env_ alloc()` donde se asigna la prioridad fija
 * se agrego una syscall: `sys_change_priority` en la cual recibe la prioriodad a otorgar y el proceso a asignarle esa prioridad. La prioridad siempre es positiva. Tambien se verifica que exista ese proceso , que tenga los permisos adecuados para cambiar la prioridad y que esta no aumente la prioirdad que el proceso ya tenia.
 * La función `sched_yield()` donde el scheduler tiene en cuenta las prioridades a la hora de determinar que proceso ejecutar.
 * La función `fork()` en la cual el proceso padre le asigna las prioridades a los procesos hijos, donde la prioridad de los hijos es dos tercios de la prioridad del padre.

##### Ejemplos de corridas:

se modificaron algunos programas para poder testear el scheduler con prioridades:

 * yield.c: Al correr make run-yield-nox primero se asignaron por unica vez la prioridad al proceso 0 y al proceso 1. En este caso se puede ver que la ejecución de los mismos es proporcional, es decir, ninguno se apodera del cpu.

``` console
SMP: CPU 0 found 1 CPU(s)
enabled interrupts: 1 2
[00000000] new env 00001000
[00000000] new env 00001001
Hello, I am environment 00001001, cpu 0
Prioridad: 256
Hello, I am environment 00001000, cpu 0
Prioridad: 256
Back in environment 00001000, iteration 0, cpu 0
Prioridad del proceso 00001000: 256
Back in environment 00001001, iteration 0, cpu 0
Prioridad del proceso 00001001: 256
Back in environment 00001001, iteration 1, cpu 0
Prioridad del proceso 00001001: 256
Back in environment 00001000, iteration 1, cpu 0
Prioridad del proceso 00001000: 256
Back in environment 00001001, iteration 2, cpu 0
Prioridad del proceso 00001001: 256
Back in environment 00001001, iteration 3, cpu 0
Prioridad del proceso 00001001: 256
Back in environment 00001001, iteration 4, cpu 0
Prioridad del proceso 00001001: 256
All done in environment 00001001
[00001001] exiting gracefully
[00001001] free env 00001001
Back in environment 00001000, iteration 2, cpu 0
Prioridad del proceso 00001000: 256
Back in environment 00001000, iteration 3, cpu 0
Prioridad del proceso 00001000: 256
Back in environment 00001000, iteration 4, cpu 0
Prioridad del proceso 00001000: 256
All done in environment 00001000
[00001000] exiting gracefully
[00001000] free env 00001000
No runnable environments in the system!
Welcome to the JOS kernel monitor!
```

* spin.c:  Al correr make run-spin-nox vemos la siguente salida. Este ejemplo es para mostrar
las diferencias de prioridades entre el padre y el hijo, como el hijo siempre
va a tener una menor prioridad que la del padre.

``` console
SMP: CPU 0 found 1 CPU(s)
enabled interrupts: 1 2
[00000000] new env 00001000
I am the parent con prioridad: 256 .  Forking the child...
[00001000] new env 00001001
I am the parent con prioridad: 256.  Running the child...
I am the child con prioridad: 170 .  Spinning...
I am the parent con prioridad: 256.  Killing the child...
[00001000] destroying 00001001
[00001000] free env 00001001
[00001000] exiting gracefully
[00001000] free env 00001000
No runnable environments in the system!
Welcome to the JOS kernel monitor!
```
* hello.c: Al correr make run-hello-nox podemos ver que los procesos hijos tiene una prioridad
menor que la de su padre (asignada en fork) (un tercio a la de su padre), por lo que no se podria aprovechar del scheduler. En este caso se puede ver una ejecucion proprocional de los procesos.

``` console
SMP: CPU 0 found 1 CPU(s)
enabled interrupts: 1 2
[00000000] new env 00001000
hello, world
prioridad proceso padre: 256
[00001000] new env 00001001
[00001000] new env 00001002
[00001000] new env 00001003
[00001000] new env 00001004
[00001000] new env 00001005
[00001000] exiting gracefully
[00001000] free env 00001000
	     	     i am environment 00001004
	     	     Hello, child 4 is now living! con prioridad: 170
	     	     	     Hello, child 4 is yielding! con prioridad: 170
	     	     	     Hello, child 4 is yielding! con prioridad: 170
	     	     i am environment 00001003
	     	     Hello, child 3 is now living! con prioridad: 170
	     	     	     Hello, child 3 is yielding! con prioridad: 170
	     	     i am environment 00001001
	     	     Hello, child 1 is now living! con prioridad: 170
	     	     	     Hello, child 1 is yielding! con prioridad: 170
	     	     i am environment 00001005
	     	     Hello, child 5 is now living! con prioridad: 170
	     	     	     Hello, child 5 is yielding! con prioridad: 170
	     	     	     Hello, child 1 is yielding! con prioridad: 170
	     	     	     Hello, child 5 is yielding! con prioridad: 170
	     	     	     Hello, child 1 is yielding! con prioridad: 170
	     	     	     Hello, child 1 is yielding! con prioridad: 170
	     	     	     Hello, child 3 is yielding! con prioridad: 170
	     	     	     Hello, child 3 is yielding! con prioridad: 170
	     	     	     Hello, child 5 is yielding! con prioridad: 170
	     	     	     Hello, child 5 is yielding! con prioridad: 170
	     	     	     Hello, child 4 is yielding! con prioridad: 170
	     	     i am environment 00001002
	     	     Hello, child 2 is now living! con prioridad: 170
	     	     	     Hello, child 2 is yielding! con prioridad: 170
	     	     	     Hello, child 2 is yielding! con prioridad: 170
	     	     	     Hello, child 1 is yielding! con prioridad: 170
	     	     	     Hello, child 2 is yielding! con prioridad: 170
[00001001] exiting gracefully
[00001001] free env 00001001
	     	     	     Hello, child 2 is yielding! con prioridad: 170
	     	     	     Hello, child 3 is yielding! con prioridad: 170
	     	     	     Hello, child 2 is yielding! con prioridad: 170
	     	     	     Hello, child 4 is yielding! con prioridad: 170
	     	     	     Hello, child 5 is yielding! con prioridad: 170
	     	     	     Hello, child 3 is yielding! con prioridad: 170
[00001005] exiting gracefully
[00001005] free env 00001005
[00001003] exiting gracefully
[00001003] free env 00001003
[00001002] exiting gracefully
[00001002] free env 00001002
	     	     	     Hello, child 4 is yielding! con prioridad: 170
[00001004] exiting gracefully
[00001004] free env 00001004
No runnable environments in the system!
Welcome to the JOS kernel monitor!

```

* stresssched.c: Se modificó este archivo para poder hacer una nueva prueba. Al correr make run-stresssched-nox
se puede ver como las prioridades de los hijos son menores que la de sus padres
y al mismo tiempo como se van ejecutando.

``` console
SMP: CPU 0 found 1 CPU(s)
enabled interrupts: 1 2
[00000000] new env 00001000
[00001000] new env 00001001
Soy el padre cuyo id es:  00001000 y prioridad: 256
[00001000] new env 00001002
Back in environment 00001000, iteration 0, cpu 0
Running 00001000 con prioridad: 256
Back in environment 00001000, iteration 1, cpu 0
Running 00001000 con prioridad: 256
Soy el segundo hijo cuyo id es: 00001002 y prioridad: 170
Back in environment 00001000, iteration 2, cpu 0
Running 00001000 con prioridad: 256
Back in environment 00001002, iteration 0, cpu 0
Running 00001002 con prioridad: 170
Soy el primer hijo cuyo id es: 00001001 y prioridad: 170
[00001001] new env 00001003
Soy primer hijo cuyo id es: 00001001 y prioridad: 170
Back in environment 00001000, iteration 3, cpu 0
Running 00001000 con prioridad: 256
Back in environment 00001000, iteration 4, cpu 0
Running 00001000 con prioridad: 256
All done in environment 00001000.
[00001000] exiting gracefully
[00001000] free env 00001000
[00001001] new env 00002000
Soy primer hijo cuyo id es: 00001001 y prioridad: 170
Back in environment 00001001, iteration 0, cpu 0
Running 00001001 con prioridad: 170
Soy el segundo nieto cuyo id es: 00002000 y prioridad: 113
Back in environment 00001001, iteration 1, cpu 0
Running 00001001 con prioridad: 170
Soy el primer nieto del primer hijo cuyo id es: 00001003 y prioridad: 113
Back in environment 00002000, iteration 0, cpu 0
Running 00002000 con prioridad: 113
Back in environment 00001001, iteration 2, cpu 0
Running 00001001 con prioridad: 170
Back in environment 00001003, iteration 0, cpu 0
Running 00001003 con prioridad: 113
Back in environment 00001001, iteration 3, cpu 0
Running 00001001 con prioridad: 170
Back in environment 00001003, iteration 1, cpu 0
Back in environment 00001001, iteration 4, cpu 0
Running 00001001 con prioridad: 170
All done in environment 00001001.
[00001001] exiting gracefully
[00001001] free env 00001001
Back in environment 00002000, iteration 1, cpu 0
Running 00002000 con prioridad: 113
Running 00001003 con prioridad: 113
Back in environment 00001003, iteration 2, cpu 0
Running 00001003 con prioridad: 113
Back in environment 00002000, iteration 2, cpu 0
Running 00002000 con prioridad: 113
Back in environment 00002000, iteration 3, cpu 0
Running 00002000 con prioridad: 113
Back in environment 00001002, iteration 1, cpu 0
Running 00001002 con prioridad: 170
Back in environment 00001003, iteration 3, cpu 0
Running 00001003 con prioridad: 113
Back in environment 00002000, iteration 4, cpu 0
Running 00002000 con prioridad: 113
All done in environment 00002000.
[00002000] exiting gracefully
[00002000] free env 00002000
Back in environment 00001002, iteration 2, cpu 0
Running 00001002 con prioridad: 170
Back in environment 00001003, iteration 4, cpu 0
Running 00001003 con prioridad: 113
All done in environment 00001003.
Back in environment 00001002, iteration 3, cpu 0
Running 00001002 con prioridad: 170
[00001003] exiting gracefully
[00001003] free env 00001003
Back in environment 00001002, iteration 4, cpu 0
Running 00001002 con prioridad: 170
All done in environment 00001002.
[00001002] exiting gracefully
[00001002] free env 00001002
No runnable environments in the system!
Welcome to the JOS kernel monitor!
```
