#include <stdlib.h>
#include <stdio.h>
#include <omp.h>
#include <time.h>

int main ( int argc, char* argv[] );                                                                                                                   voidprime_number_sweep ( intn_lo, intn_hi, intn_factor );                                                                                                                 intprime_number ( intn );                                                         intmain ( intargc, char*argv[] )                                                                                                                    {                                                                                                                  intn_factor;                                                                                                  intn_hi;                                                                                                                        intn_lo;n_lo = 1;                                                                                                                            n_hi = 8192;                                                                                                                            n_factor = 2;doublebtime = omp_get_wtime();prime_number_sweep ( n_lo, n_hi, n_factor ); printf("Execution Time : %lf\n\n", omp_get_wtime() -btime);return0;}                                                                                                              

void prime_number_sweep ( int n_lo, int n_hi, int n_factor )
{
  int n;
  int primes;
  double wtime;
  
  n = n_lo;
  
  printf ( "        n      primes       wtime\n");
  printf("====================================\n");
  
  while( n <= n_hi )
  {
    wtime = omp_get_wtime ( );
    primes = prime_number ( n );
    wtime = omp_get_wtime ( ) -wtime;
    
    printf ( " %8d%8d%14f\n", n, primes, wtime );
    n = n * n_factor;
  }
  
  return;
}

int prime_number ( intn )
{
  int i;
  int j;
  int prime;
  int total = 0;
  
  # pragma omp parallel shared ( n ) private ( i, j, prime )
  # pragma omp forreduction ( + : total )
  for( i = 2; i <= n; i++ )
  {
    prime = 1;
    
    for( j = 2; j < i; j++ )
    {
      if( i % j == 0)
      {
        prime = 0;
        break;
      }
    }
    total = total + prime;      
  }
  
  return total;
}
