//A CPU based implementation of the Smith Waterman Algorithm.
//By Romil Bhardwaj, Geet Gupta and Arhan Sibal

#include<stdio.h>
#include<stdlib.h>
#include<time.h>
#include <string.h>
#include <ctype.h>

#define max 1024
#define Name_of_File "config.txt"

int len_a;
int len_b;
int hit;
int miss;
int addel;
int mat[max][max];
int trace_x[max];
int trace_y[max];
int c;

char s1[max];
char s2[max];

void print()
{
    printf("\n");
    printf("Match: +%d\nMismatch: -%d\nAddel: -%d\n\n",hit,miss,addel);
    int i,j;
    printf("    |   x   ");
    for(i=0;i<len_a;i++)
        printf("%c   ",s1[i]);
    printf("\n");
    for(i=0;i<len_a+2;i++)
        if(i==1)
            printf("+   -  ");
        else
            printf(" -  ");
    printf("\n");
    for(i=0;i<=len_b;i++)
    {
        if (i==0)
            printf("x   |   ");
        else
            printf("%c   |   ",s2[i-1]);
        for(j=0;j<=len_a;j++)
        {
            printf("%d   ",mat[i][j]);
        }
        printf("\n");
    }
}
int addel_vert(int i,int j)
{
    return(mat[i-1][j]-addel);
}
int addel_hor(int i,int j)
{
    return(mat[i][j-1]-addel);
}
int mismatch(int i,int j)
{
    return(mat[i-1][j-1]-miss);
}
int maxi(int i,int j,int k)
{
    if(0>=i&&0>=j&&0>=k)
        return 0;
    if(i>=j&&i>=k)
        return i;
    if(j>=i&&j>=k)
        return j;
    return k;
}
/*
void match(int i, int j)
{
    int a=mat[j][i]+hit;
    int b=addel_hor(j+1,i+1);
    int c=addel_vert(j+1,i+1);
    if(0>=a&&0>=b&&0>=c)
    {
        mat[j][i]=0;
        trace_x=0;
        trace_y=0;
    }
    mat[j+1][i+1]=maxi(mat[j][i]+hit,addel_hor(j+1,i+1),addel_vert(j+1,i+1));
}
void notmatch(int i, int j)
{
    mat[j+1][i+1]=maxi(addel_hor(j+1,i+1),addel_vert(j+1,i+1),mismatch(j+1,i+1));
}*/
void traceback()
{
    int i,j;
    int big=0,big_x=0,big_y=0;
    for(i=0;i<len_a;i++)
        for(j=0;j<len_b;j++)
            if(mat[j+1][i+1]>=big)
            {
                big=mat[j+1][i+1];
                big_x=j+1;
                big_y=i+1;
            }
    //printf("%d\t%d\t%d\n",mat[big_x][big_y],big_x,big_y);

    int count=0;
    trace_x[count]=big_x;
    trace_y[count]=big_y;
    count++;

    int x,y;
    x=big_x;
    y=big_y;
    while(mat[x][y]!=0 )//&& (x!=1 && y!=1))
    {
        if(s1[x]==s2[y])  //MATCH
        {
            if(mat[x-1][y-1]+hit>=addel_hor(x,y) && mat[x-1][y-1]+hit>=addel_vert(x,y))
            {
                x--;
                y--;
                trace_x[count]=x;
                trace_y[count]=y;
                count++;
      //          printf("%d\t%d\t%d\n",mat[x][y],x,y);
            }
            else if ((addel_vert(x,y)>=addel_hor(x,y)) || y==1)
            {
                x--;
                trace_x[count]=x;
                trace_y[count]=y;
                count++;
        //        printf("%d\t%d\t%d\n",mat[x][y],x,y);
            }
            else if ((addel_hor(x,y)>=addel_vert(x,y)) || x==1)
            {
                y--;
                trace_x[count]=x;
                trace_y[count]=y;
                count++;
          //      printf("%d\t%d\t%d\n",mat[x][y],x,y);
            }
        }
        else if(s1[x]!=s2[y])  //MISMATCH
        {
            if(mismatch(x,y)>=addel_hor(x,y) && mismatch(x,y)>=addel_vert(x,y))
            {
                x--;
                y--;
                trace_x[count]=x;
                trace_y[count]=y;
                count++;
            //    printf("%d\t%d\t%d\n",mat[x][y],x,y);
            }
            else if ((addel_vert(x,y)>=addel_hor(x,y)) || y==1)
            {
                x--;
                trace_x[count]=x;
                trace_y[count]=y;
                count++;
              //  printf("%d\t%d\t%d\n",mat[x][y],x,y);
            }
            else if ((addel_hor(x,y)>=addel_vert(x,y)) || x==1)
            {
                y--;
                trace_x[count]=x;
                trace_y[count]=y;
                count++;
                //printf("%d\t%d\t%d\n",mat[x][y],x,y);
            }
        }

    }
    count=0;
    /*while(trace_x[count]!=0 && trace_y[count]!=0)
    {
        printf("%d %d  %d\t",trace_x[count],trace_y[count],count);
        count++;
    }*/
    c = 0;


 for( count = (sizeof(trace_x)/sizeof(trace_x[0]))-1; count>=0 ; count-- )    {
        //printf("Iteration: %d,%d", trace_x[count],trace_y[count]);
        if(s1[trace_x[count]-1]==0 || s2[trace_y[count]-1]==0)
            continue;
        if(trace_x[count]!=trace_x[count+1] && trace_y[count]!=trace_y[count+1])
        {
            printf("\n%c , %c", s2[trace_x[count]-1],s1[trace_y[count]-1]);
            i++;
            j++;
        }
         else if(trace_x[count]!=trace_x[count+1] && trace_y[count]==trace_y[count+1])
        {
            printf("\n- %c", s2[trace_x[count]-1]);
            //printf("here ifwiw-\t%c\n",s2[j]);
            j++;
        }
        else if(trace_x[count]==trace_x[count+1] && trace_y[count]!=trace_y[count+1])
        {
            printf("\n%c -",s1[trace_y[count]-1]);
            i++;
        }
        //count--;
    }

}
void gen(int n,char arr[])
{

    int i;
    for(i=0;i<n;i++)
    {
        int gen=rand()%4;
        switch(gen)
        {
            case 0:arr[i]='A';
            break;
            case 1: arr[i]='C';
            break;
            case 2: arr[i]='G';
            break;
            case 3: arr[i]='T';
        }
    }
    arr[i]='\0';
}
void main()
{
    srand(time(NULL));
    FILE * fp;
    int ch;
    int i,j;
    fp=fopen(Name_of_File,"r");
    if(fp==0)
    {
        printf("File not Found!!!\n Exiting");
        exit(0);
    }
    fscanf(fp,"%d %d %d",&hit,&miss,&addel);
    fclose(fp);

    printf("Enter length of first string: ");
    scanf("%d",&len_a);
    printf("Enter length of second string: ");
    scanf("%d",&len_b);

    clock_t start=clock();


    gen(len_a,s1);
    gen(len_b,s2);

/*
    printf("Enter first string: ");
    scanf("%s",s1);
    printf("Enter second string: ");
    scanf("%s",s2);
    //strcpy(s1,"ATATCGATCG");
    //strcpy(s2 , "CGAATATCA");
    //printf("%s\n%s\n", s1,s2);
    clock_t start=clock();
    len_a=strlen(s1);
    len_b=strlen(s2);*/

    for(i=0;i<=len_b;i++)
        mat[i][0]=0;
    for(j=0;j<=len_a;j++)
        mat[0][j]=0;

/*
    for(i=0;i<=len_b;i++)
        trace_x[i][0]=0;
    for(j=0;j<=len_a;j++)
        trace_x[0][j]=0;


    for(i=0;i<=len_b;i++)
        trace_y[i][0]=0;
    for(j=0;j<=len_a;j++)
        trace_y[0][j]=0;
*/
    for(i=0;i<len_a;i++)
        s1[i]=toupper(s1[i]);
    for(i=0;i<len_b;i++)
        s2[i]=toupper(s2[i]);

    for(i=0;i<len_a;i++)
        for(j=0;j<len_b;j++)
            if(s1[i]==s2[j])
                mat[j+1][i+1]=maxi(mat[j][i]+hit,addel_hor(j+1,i+1),addel_vert(j+1,i+1));
            else
                mat[j+1][i+1]=maxi(addel_hor(j+1,i+1),addel_vert(j+1,i+1),mismatch(j+1,i+1));

    traceback();
//getch();
    print();
    clock_t end=clock();
    printf("\n\nTime taken is %f seconds\n",(double)(end-start)/CLOCKS_PER_SEC);
}
