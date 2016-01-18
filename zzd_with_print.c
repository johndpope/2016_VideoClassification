#include "mex.h"
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include "matrix.h"
#include <omp.h>

void mexFunction(int nlhs, mxArray *plhs[], int nrhs,const mxArray *prhs[])
{
    mxArray *cell_element_ptr;
    char* last_dir = "*.flo |wc -l>>count.txt";
    char digit;
    float *outData;char databuf[4];
    mwSize number_of_dimensions, buflen;
    int N1,N2,i,width,height,flag,count,max,filecount,selected,in;
    float tag,data;
    N1 = mxGetN(prhs[0]);
    count=0;max=320*2*240*10*N1;
    plhs[0]=mxCreateNumericMatrix(1,320*2*240*10*N1,mxSINGLE_CLASS,mxREAL);
    outData=mxGetPr(plhs[0]);
    #pragma omp parallel for
    for (i=0;i<N1;i++){
        char prefix_dir[250]="ls -lR ";
        cell_element_ptr = mxGetCell(prhs[0],i);
        N2 = mxGetN(cell_element_ptr);
        buflen = mxGetNumberOfElements(cell_element_ptr) + 1;
        char* buf = mxCalloc(buflen, sizeof(char));
        if (mxGetString(cell_element_ptr, buf, buflen) != 0){
        mexErrMsgIdAndTxt( "MATLAB:explore:invalidStringArray","Could not convert string data.");
        }
        mexPrintf("dirname:%s\n",buf);
        strcat(prefix_dir,buf);
        strcat(prefix_dir,last_dir);
        system(prefix_dir);
        FILE *dp = fopen("count.txt","r");
        filecount=0;
        while(!feof(dp)){
             digit=fgetc(dp);
             if(digit>='0'&&digit<='9') 
                 filecount = filecount*10 + digit-'0';
        }
        fclose(dp);
        system("rm count.txt");
        if (filecount <= 10) selected = 0;
        else  selected = (int)rand()%(filecount-9);
        mexPrintf("selected:%d\n",selected);
        for (in=0;in<=9;in++){
            char filename[250];
            sprintf(filename,"%sflownets-pred-%07d.flo",buf,selected+in);
            mexPrintf("filename:%s\n",filename);
            FILE *fp = fopen(filename,"rb+");
            flag=0;
            while(!feof(fp)){
                if (flag==0){
                    fscanf(fp,"%4c",databuf);
                    tag = *(float*)databuf;
                    fscanf(fp,"%4c",databuf);
                    width = *(int*) databuf;
                    fscanf(fp,"%4c",databuf);
                    height = *(int*) databuf;
                    flag=1;
                }
                fscanf(fp,"%4c",databuf);
                data = *(float*)databuf;
                outData[count++] = data;
                if(count>=max){
                     mexPrintf("some data is not common!");
                     break;
                }
            }
        fclose(fp);
        }
    }
}
