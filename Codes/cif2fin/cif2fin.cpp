#include <iostream>
#include <sstream>
#include <fstream>
#include <strstream>
using namespace std;

string name(string str)
{
    int location,lens;
    int len,index;
    string s=str;
	lens=s.length();
	location=s.find_last_of("/");
	string ss=s.substr(location+1,lens-location);
	int n=ss.find_last_of(".");
	ss.erase(n,4);
    return ss;
}
int judge(string str)
{
    if(str[0]=='S')
    {
        if(str[1]=='i')
            return 1;
    }
    else if(str[0]=='O')
    {
        return 2;
    }
    else
        return 0;
}
void modify(string str1,string str2)
{
	string str,li,word[1000],temp,temp1,temp2,data[6],line[10000];
	bool flag=true,flag1=true,flag2=false;
	int i,k=0,count=0;
	ifstream openfile(str1.c_str());
    ofstream outfile(str2.c_str());
    if(!openfile)
    {
        cout<<"Error!";
        return;
    }
    outfile<<"TITL "<<name(str1)<<endl;
    li=name(str1)+".fout";
    outfile<<"OUTF "<<li<<endl;
    outfile<<"CELL   ";
    while(getline(openfile,str))
    {
    	i=0;
    	stringstream s(str);
    	while(s>>word[i])
    	{
    		i++;
    	}
    	if(flag==true)
    	{
    		for(int j=0;j<i;j++)
    		{
    			if(word[j]=="_symmetry_space_group_name_H-M")
    			{
    				temp1=word[j+1];
    				temp1.erase(0,1);
    				temp2=word[j+2];
    				int l=temp2.find_last_of("'");
    				temp2.erase(l,1);
    				flag=false;
    				temp=temp1+temp2;
    				break;
    			}
    		}
    	}
    	if(flag1==true)
    	{
    		if(word[0]=="_cell_length_a"||word[0]=="_cell_length_b"||word[0]=="_cell_length_c"||word[0]=="_cell_angle_alpha"||word[0]=="_cell_angle_beta"||word[0]=="_cell_angle_gamma")
    		{
    			data[k++]=word[1];
    		}
    		if(k==6)
    			flag1=false;
    	}


        if(word[0]=="_atom_site_occupancy")
        	flag2=true;
        if(flag2==true)
        {
        	int m=judge(word[0]);
        	if(m==1||m==2)
        	{
        	    strstream ss;
        	    string mm;
        	    ss<<m;
        	    ss>>mm;
        		line[count++]=word[0]+"  "+mm+" "+"@   "+word[1]+"  "+word[2]+"  "+word[3];
        	}
        }

    }
    for(int j=0;j<6;j++)
    {
    	outfile<<data[j]<<"  ";
    }
    outfile<<"\n"<<"SPGR "<<temp<<"\n"<<"ENVI 1 1 1\nTYPE 2\n1 Si 1 4 0 0 10\n2 O  1 2 0 0 10\nBOND 1\n1 2 1.8 1 1.605 0 0 20\nD1_3 2\n2 1 2 1 2.6 0 0 4\n1 2 1 1 3.1 0 0 4\nNCYC 0\nUNIQ  "<<count<<endl;
    for(int j=0;j<count;j++)
    	outfile<<line[j]<<endl;
    outfile<<"END"<<endl;
}
int main(int argc,char * argv[])
{
    string cif,txt;
    //cout<<"please input the \"cif\" filename:"<<endl;
    //cin>>cif;
    //cout<<"please input the \"txt\" filename:"<<endl;
    //cin>>txt;
    cif=argv[1];
    txt=argv[2];
    modify(cif,txt);
	return 0;
}
