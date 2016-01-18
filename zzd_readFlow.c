#include "mex.h"
#include <string.h>
#include <stdio.h>
#include "matrix.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs,const mxArray *prhs[])
{
    mxArray *cell_element_ptr;
    char *buf;float *outData;char databuf[4];
    mwSize number_of_dimensions, buflen;
    int N1,N2,i,width,height,flag,count;
    float tag,data;
    N1 = mxGetN(prhs[0]);
    plhs[0]=mxCreateNumericMatrix(320*2,240*N1,mxSINGLE_CLASS,mxREAL);
    outData=mxGetPr(plhs[0]);
    for (i=0;i<N1;i++){
        flag=0;
        cell_element_ptr = mxGetCell(prhs[0],0);
        N2 = mxGetN(cell_element_ptr);
        buflen = mxGetNumberOfElements(cell_element_ptr) + 1;
        buf = mxCalloc(buflen, sizeof(char));
        if (mxGetString(cell_element_ptr, buf, buflen) != 0){
        mexErrMsgIdAndTxt( "MATLAB:explore:invalidStringArray","Could not convert string data.");
        }
        mexPrintf("filename:%s\n",buf);
        FILE *fp = fopen(buf,"rb+");
        count=0;
        while(!feof(fp)){
            if (flag==0){
              fscanf(fp,"%4c",databuf);
              tag = *(float*)databuf;
              fscanf(fp,"%4c",databuf);
              width = *(int*) databuf;
              fscanf(fp,"%4c",databuf);
              height = *(int*) databuf;
              mexPrintf("tag%f\n",tag);        
              mexPrintf("tag%d\n",width);
              mexPrintf("tag%d\n",height);
              flag=1;
            }
            fscanf(fp,"%4c",databuf);
            data = *(float*)databuf;
            outData[count++] = data;
        }
        fclose(fp);
    }
}
