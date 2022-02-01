#include<stdio.h>
#include<unistd.h>

#define BUFLEN 1024

int is_palindrome(char* s, int len);
int addstr(char* a, char* b);
int factstr(char* s);
int fact(int n);
int is_palindromeC(char* s, int len);
void palindrome_check();

int main() {
  char ans;
  char a[BUFLEN];
  char b[BUFLEN];
  int count;
  printf("1) Add two numbers together\n");
  printf("2) Test if a string is a palindrome (C -> ASM)\n");
  printf("3) Print the factorial of a number\n");
  printf("4) Test if a string is a palindrome (ASM -> C)\n");
  scanf("%c", &ans);
  switch (ans) {
  case '1':
    printf("Enter the first number:\n");
    read(0, a, BUFLEN);
    printf("Enter the second number:\n");
    read(0, b, BUFLEN);
    printf("Result = %d\n", addstr(a, b));
    break;
  case '2':
    printf("Enter a string to test:\n");
    count = read(0, a, BUFLEN);
    if (is_palindrome(a, count-1)) {
      printf("It is a palindrome.\n");
    }
    else {
      printf("It is NOT a palindrome.\n");
    }
    break;
  case '3':
    printf("Enter a number:\n");
    read(0, a, BUFLEN);
    printf("Result = %d\n", factstr(a));
    break;
  case '4':
    palindrome_check();
    break;
  default:
    printf("Invalid option. Exiting...\n");
  }
  return 0;
}

int fact(int n) {
  if (n == 0)
    return 1;
  else
    return n*fact(n-1);
}

int is_palindromeC(char* s, int len) {
  int i, j;
  for (i = 0, j = len - 1; i < len/2; i++, j--)
    if (s[i] != s[j]) return 0;
  return 1;
}
