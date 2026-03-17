!
! Framework Generator (V4.2_20120802)
!
! Yi Li (yili@jlu.edu.cn)
! State Key Laboratory of Inorganic Synthesis and Preparative Chemistry
! Jilin University, Qianjin Street 2699, Changchun 130012, China PR
!
!
! V1.5 simulation without maps is allowed
!      initial value of econbst is corrected
!      output of cell parameters is corrected
! V1.6 library of wyckoff positions and asymmetric unit could be specified
!      multiplicity for each atom could be seen in the output file
!      mumber of atoms is listed in the list file and the csq file
! v1.7 function "getdist" rewritten to enhance the performance
!      cycles will be terminated if EBST is larger than COSTBAD after NTRIALBAD steps
! v2.0 input as keywords
!      list file has headers now
! v2.1 cost5 (restraint on relative structure factors) has been addad
!      input keywords have been modified
! v2.2 cost5 revised. R factor is used instead of relative structure factors
! v2.3 the dimensions of X11 and X22 changed from 3 to 2
!      NTYPEMAX is used instead of NTMAX
! v2.4 wyckoff positions could be determined more wisely (SYMM2)
!      fix the IASYM>=1 bug when writing the output header
!      atom names are required as input
!      fix the bug of the dimension of "BOND" in subroutine COST2
!      fix the bug of the dimension of "F2" in subroutine GETF
!      XDMAX, YDMAX, ZDMAX should be negative if the user wants to neglect the initial atomic positions
!      initial value of NTRIALBAD has been changed to -1
!      correct the initial value for "INTDENS"
! v2.5 add formula constraint, keyword is 'FORM'
!      atoms will not be generated on the same special position with fixed coordinates (SYMM1)
!      fix the bug when generating the output of 1-3 distance constants
!      fix the initial values for all the cost functions to be 0, i.e., fc1, fd1, fb1, etc.
!      modify the format of output of all the cost functions
!      csq output is revised
!      12 shells of csq are calculated
! v3.0 use modules to replace common blocks
!      remove all the GOTO's and labels
!      asymmetric unit function is disabled
!      new random number generator
!      random coordinates will be given to atoms with XDMAX, YDMAX, ZDMAX larger than 0.5; values less than 0 means the atom is fixed
!      9 potential functions are enabled
!      "INTDENS" is disabled
!      input and output are enhanced
!      the multiplicities of structure factors are used as the default weights
!      content constraints are enhanced, input is easier now
! v3.1 new convergence test
!      unique atoms can be ignored randomly, if the wyckoff position is "?"
!      content constraint revised
! v3.2 fix the bug on judging special wyckoff sites (ispecial)
! v3.3 fix the bug on calcuating coordination sequences when the last atom is removed
!      a forbidden wyckoff position list is introduced for each atom
!      STOP is merged with STEP as the 2nd - 4th arguments
! v3.4 thresholds for list, csq, and output files are introduced
!      a new file filewyck is introduced to record the wyckoff positions of each atom during simulation
!      former filewyck is changed to filesymm
!      cost summation revised, multiplicity of each atom is considered
! v3.5 a new constraint on the number of atoms at each wyckoff position is introduced (NWYC)
!      the old variables NWYCK and NWYCK1 are changed to IWYCK and IWYCK1
! v3.6 filewyck format revised
!      fragen can read wyckoff positions in another file now
! v3.7 ENVI, ENVI2, GETCSQ improved
!      BOX revised
! v3.7.1  linemax increased from 132 to 512
!         minor improvement in getf0 and cost5
! v4.0 list and csq files are not necessary for single point calculation
!      five new functions added
!      statistics on bonding geometry was added for single point calculation
!      keyword LATT added
!      maximum number of unique atoms was increased to 2500 from 300
! v4.1 BOX revised
!      keywords ENVA, ENVB, ENVC added
! v4.2 tiny improvement on bonding statistics output
!      nint used in hklweight
!      character lengths in mytrim revised
!      CSQ and OUT files format revised
!      a bug in symm2 when is fixed


module parameters
save
integer, parameter :: ntmax= 2500, ntypemax= 50, ntallmax= 5000, ngmax= 2000000, nmapmax= 3, nbox=12, linemax= 512
integer, parameter :: nconmax= 100, nbmax= 5000, nshellmax= 12, nformmax= 50, nstgmax= 20, ntrymax= 20, nhklmax= 1000
integer, parameter :: nbondtypemax= 400, ntypebondmax=10000, nangletypemax=600, ntypeanglemax=15000
real, parameter :: pi = 3.1415926535897932, boltz= 1.38065E-23
end module parameters
module cell
save
real :: alength,blength,clength,coal,cobe,coga
end module cell
module cell2
save
real :: a2,b2,c2,abcoga2,accobe2,bccoal2
end module cell2
module grid
use parameters
save
integer, dimension(nmapmax) :: na,amin,amax,nb,bmin,bmax,nc,cmin,cmax
end module grid
module atomtype
use parameters
save
integer :: ntype
integer, dimension(ntmax) :: iatom
real, dimension(3,ntypemax) :: border
end module atomtype
module fcc
use parameters
save
integer, dimension(ntypemax) :: fc1
real, dimension(ntypemax) :: fc2, fc3, fc4, fc5
end module fcc
module fcd
use parameters
save
integer, dimension(ntypemax,nmapmax) :: fd1
real, dimension(ntypemax,nmapmax) :: fd2, fd3, fd4, fd5
end module fcd
module fcb
use parameters
save
integer, dimension(ntypemax,ntypemax) :: fb1
real, dimension(ntypemax,ntypemax) :: fb2, fb3, fb4, fb5, dtmax
real :: enva, envb, envc
real, dimension(ntypebondmax,nbondtypemax) :: d12type
integer, dimension(ntypebondmax,nbondtypemax) :: nd12
integer, dimension(nbondtypemax) :: nd12type, named12type(2,nbondtypemax)
integer, dimension(ntypemax,ntypemax) :: id12type
end module fcb
module fca
use parameters
save
integer, dimension(ntypemax,ntypemax,ntypemax) :: fa1
real, dimension(ntypemax,ntypemax,ntypemax) :: fa2, fa3, fa4, fa5
real, dimension(ntypeanglemax,nangletypemax) :: a13type
integer, dimension(ntypeanglemax,nangletypemax) ::  na13
integer, dimension(nangletypemax) :: na13type, namea13type(3,nangletypemax)
integer, dimension(ntypemax,ntypemax,ntypemax) :: ia13type
end module fca
module fcu
use parameters
save
integer, dimension(ntypemax,ntypemax,ntypemax) :: fu1
real, dimension(ntypemax,ntypemax,ntypemax) :: fu2, fu3, fu4, fu5
real, dimension(ntypeanglemax,nangletypemax) :: d13type
integer, dimension(ntypeanglemax,nangletypemax) :: nd13
integer, dimension(nangletypemax) :: nd13type, named13type(3,nangletypemax)
integer, dimension(ntypemax,ntypemax,ntypemax) :: id13type
end module fcu
module rfactor
use parameters
save
real, dimension(nhklmax) :: fo, weight, ds
real :: wcost5,f2max,fomax,weightsum
end module rfactor
module symmetry
save
integer, DIMENSION(27) :: np,ispecial
character, dimension(27) :: wyck*1, site*20
REAL, dimension(12,192,27) :: matrix
integer :: nsym
character :: family
end module symmetry



program FG

use parameters
use cell
use cell2
use grid
use atomtype
use fcc
use fcd
use fcb
use fca
use fcu
use rfactor
use symmetry

character(len = 32) :: filein,fileout,filelst,filecsq,filelog,filesymm,filesfac,filewyck,fileread
character :: spg*8, spglong*32
character(len = 32), dimension(nmapmax) :: denmap
integer, dimension(nshellmax,ntmax) :: ncs
character(len = 1), dimension(ntmax) :: wyck1,wyckcode
integer, dimension(nstgmax) :: naccept, nswap, istage
real, dimension(nstgmax) :: rswap
real, dimension(ntmax,nstgmax) :: ed1, eb1, ec1, eu1, ea1, e31
real, dimension(ntmax,0:ntrymax) :: ed2, eb2, ec2, eu2, ea2, e32
real, dimension(nstgmax) :: edens1, ebond1, econ1, eub1, eang1, e3mr1
real, dimension(0:ntrymax) :: edens2, ebond2, econ2, eub2, eang2, e3mr2
integer, dimension(ntmax,nstgmax) :: iup1, iup2
real(8), dimension(nstgmax) :: t
real, dimension(nstgmax) :: deltax, deltay, deltaz
integer, dimension(nstgmax) :: ntry
integer, dimension(ngmax) :: ng
real, dimension(ngmax,nmapmax) :: dens0,dens1(ntallmax,nmapmax,nstgmax),dens2(ntallmax,nmapmax,0:ntrymax)
real, dimension(ntmax,nstgmax) :: x1, y1, z1
real, dimension(0:ntrymax) :: x2, y2, z2
real(8), dimension(ntrymax) :: e1(nstgmax), e2(0:ntrymax), e3, expe
real, dimension(ntmax) :: xbst, ybst, zbst, xini, yini, zini, xdmax, ydmax, zdmax
integer, dimension(ntmax) :: iwyck, iwyck1
character (len=1), dimension(27,ntmax) :: forb
character (len=1), dimension(27) :: wyckn
integer, dimension(27) :: nwyck1,nwyck2
logical, dimension(ntmax) :: fixatom
real, dimension(ntallmax,nstgmax) :: x11, y11, z11
real, dimension(ntallmax,0:ntrymax) :: x22, y22, z22
real, dimension(nconmax,ntmax,0:ntrymax) :: dist2
integer, dimension(ntmax,0:ntrymax) :: bond2(4,nconmax,ntmax,0:ntrymax), ncon2
real, dimension(nconmax,ntmax,nstgmax) :: dist1
integer, dimension(ntmax,nstgmax) :: bond1(4,nconmax,ntmax,nstgmax), ncon1
character, dimension(ntmax) :: atom*5
character, dimension(ntypemax) :: element*4
integer, dimension(ntallmax) :: ip(2,ntmax), ipp
integer, dimension(nhklmax) :: h0, k0, l0
real, dimension(3,nhklmax,nstgmax) :: f1,f2(3,nhklmax,0:ntrymax),f01(2,nhklmax,ntmax,nstgmax), &
f02(2,nhklmax,ntmax,0:ntrymax),f(ntmax,nhklmax)
real, dimension(nstgmax) :: ef1,ef2(0:ntrymax)
integer, dimension(ntmax,nformmax) :: cform,vform1(nformmax),vform2(nformmax)
INTEGER, DIMENSION(99) :: seed
integer :: clock
character :: datecyc1*8,datecyc2*8,timecyc1*10,timecyc2*10,datejob1*8,datejob2*8,timejob1*10,timejob2*10
character(len=linemax) :: line, title, key*4
real(8) :: ebst,tmp8,p1,p2,wn,wo,e2min,e3min
logical :: isopen,defout,deflst,defcsq,deflog,defwyck,defread

integer iidenx
character(len = 32) :: path

call get_command_argument(1,value=filein,status=iostatus)


CALL SYSTEM_CLOCK(COUNT = clock)
CALL RANDOM_SEED(size = nseed)

fc1= 0
fd1= 0
fa1= 0
fb1= 0
fu1= 0
fc5= -1
fd5= -1
fa5= -1
fb5= -1
fu5= -1
filesymm= 'wyckfull.dat'
filesfac= 'sf_5g.dat'
fileout=''
filelst=''
filecsq=''
filelog=''
filewyck=''
fileread=''
defout=.false.
deflst=.false.
defcsq=.false.
deflog=.false.
defwyck=.false.
defread=.false.
nmap= 0
ntype= 0
border= 0
nfb= 0
nfu= 0
nfa= 0
nhkl= 0
w3mr= -1
nuniq= 0
ncycle= 0
nstage= 0
ntrial= 10000
ntrialbad= -1
nconverge= -1
costbad= -999999
seed= 0
noutput= -1
nsave= -1
minnt= 0
maxnt= 0
nform= 0
cform= 0
fo= 0.0000001
weight= -1
xdmax= 0.5
ydmax= 0.5
zdmax= 0.5
fixatom= .false.
forb= ' '
tcsq= -1
tlst= -1
tout= -1
twyck= -1
wyck1= '?'
d12type=0
a13type=0
d13type=0
nd12type=0
na13type=0
nd13type=0
nd12=0
nd13=0
na13=0
enva=0.5
envb=0.5
envc=0.5

if (len_trim(filein).eq.0) then
  write(0,*)
  write(0,*)'#########################################################################'
  write(0,*)'#                  Framework Generator (v4.2_20120802)                  #'
  write(0,*)'#                                                                       #'
  write(0,*)'#                       Yi Li  (yili@jlu.edu.cn)                        #'
  write(0,*)'# State Key Laboratory of Inorganic Synthesis and Preparative Chemistry #'
  write(0,*)'#   Jilin University, Qianjin Street 2699, Changchun 130012, China PR   #'
  write(0,*)'#########################################################################'
  write(0,'(/,x,a)', advance = 'no')'Input instruction file name: '
  read(*,*)filein
  write(0,*)
endif
!zouwy: get the path of input file
open(unit = 12, file = trim(filein), status = 'old')
iindex=index(filein,'/',.true.)

! read input file

readinput:  do
  do i= 1,linemax
    line(i:i)= ' '
  enddo
  key= '    '
  read (12, '(a)',iostat=iostatus) line
  call nocomment(line)
  if (is_iostat_end(iostatus)) exit readinput
  !if (iostatus.lt.0) exit readinput
  read(line, *, iostat = iostatus )key
  !    if (is_iostat_eor(iostatus)) cycle readinput
  if (key(1:1).eq.'!'.or.key(1:1).eq.'#') cycle readinput
  do i= 1, 4
    if (key(i:i).GE.'a'.AND.key(i:i).LE.'z') then
    key(i:i) = char(ichar(key(i:i)) - ichar('a') + ichar('A'))
    endif
  enddo
  select case (key)
    case('TITL'); read(line,'(2a)')key,title; call nocomment(title)
    case('OUTF'); read(line,*,iostat=iostatus)key,fileout,tout
      if (len_trim(fileout).lt.1) then
        write(0,*)'cannot find filename after ',key
        close(12)
        stop
      endif
      defout=.true.
    case('LSTF'); read(line,*,iostat=iostatus)key,filelst,tlst
      if (len_trim(filelst).lt.1) then
        write(0,*)'cannot find filename after ',key
        close(12)
        stop
      endif
      deflst=.true.
    case('CSQF'); read(line,*,iostat=iostatus)key,filecsq,tcsq
      if (len_trim(filecsq).lt.1) then
        write(0,*)'cannot find filename after ',key
        close(12)
        stop
      endif
      defcsq=.true.
    case('WYCF'); read(line,*,iostat=iostatus)key,filewyck,twyck
      if (len_trim(filewyck).lt.1) then
        write(0,*)'cannot find filename after ',key
        close(12)
        stop
      endif
      defwyck=.true.
    case('READ'); read(line,*,iostat=iostatus)key,fileread
      if (len_trim(fileread).lt.1) then
        write(0,*)'cannot find filename after ',key
        close(12)
        stop
      endif
      defread=.true.
    case('LOGF'); read(line,*,iostat=iostatus)key,filelog
      if (len_trim(filelog).lt.1) then
        write(0,*)'cannot find filename after ',key
        close(12)
        stop
      endif
      deflog=.true.
    case('SYMM'); read(line,*,iostat=iostatus)key,filesymm
      if (iostatus.ne.0) then
        write(0,*)'cannot find filename after ',key
        close(12)
        stop
      endif
    case('SFAC'); read(line,*,iostat=iostatus)key,filesfac
      if (iostatus.ne.0) then
        write(0,*)'cannot find filename after ',key
        close(12)
        stop
      endif
    case('DENF'); read(line,*)key,nmap
      if (nmap.gt.nmapmax) then
        write(0,*)'Too many maps!'
        close(12)
        stop
      endif
      if (nmap.gt.0) then
        ng = 0
        readmap: do i= 1,nmap
          read(12,*)denmap(i)
          open(unit = 20, file = trim(denmap(i)), status = 'old')
          read(20,*)
          read(20,*)
          read(20,*)
          read(20,*)na(i),amin(i),amax(i),nb(i),bmin(i),bmax(i),nc(i),cmin(i),cmax(i)
          na(i)=amax(i)-amin(i)+1
          nb(i)=bmax(i)-bmin(i)+1
          nc(i)=cmax(i)-cmin(i)+1
          if(na(i)*nb(i)*nc(i).gt.ngmax) then
            write(0,*)'Error on reading grid points: Too many grids in ',denmap(i)
            close(20)
            close(12)
            stop
          endif
          read(20,*)
          read(20,*)
          do iz=cmin(i),cmax(i)
            read(20,*)ncindex
            do iy=bmin(i),bmax(i)
              do ix=amin(i),amax(i)
              read(20,*,iostat=iostatus)tmp
                if (iostatus.lt.0) then
                  close(20)
                  cycle readmap
                endif
                ng(i)=ng(i)+1
                dens0(ng(i),i)=tmp
              enddo
            enddo
          enddo
        enddo readmap
      endif
    case('CELL'); read(line,*)key,alength,blength,clength,al,be,ga
      coal=cos(al*pi/180.0)
      cobe=cos(be*pi/180.0)
      coga=cos(ga*pi/180.0)
      sial=sin(al*pi/180.0)
      sibe=sin(be*pi/180.0)
      siga=sin(ga*pi/180.0)

      a2=alength**2
      b2=blength**2
      c2=clength**2
      abcoga2 = 2*alength*blength*coga
      accobe2 = 2*alength*clength*cobe
      bccoal2 = 2*blength*clength*coal
    case('LATT')
      read(12,*)alength
      read(12,*)blength
      read(12,*)clength
      read(12,*)al
      read(12,*)be
      read(12,*)ga
      coal=cos(al*pi/180.0)
      cobe=cos(be*pi/180.0)
      coga=cos(ga*pi/180.0)
      sial=sin(al*pi/180.0)
      sibe=sin(be*pi/180.0)
      siga=sin(ga*pi/180.0)

      a2=alength**2
      b2=blength**2
      c2=clength**2
      abcoga2 = 2*alength*blength*coga
      accobe2 = 2*alength*clength*cobe
      bccoal2 = 2*blength*clength*coal
    case('SPGR'); read(line,'(2a)')key,spglong
      call mytrim(spglong,spg,32,8,lenspg)
      do i= 1, 8
        if (i.le.lenspg) then
          if (spg(i:i).ge.'a'.and.spg(i:i).le.'z') then
            spg(i:i) = char(ichar(spg(i:i)) - ichar('a') + ichar('A'))
          endif
        else
          spg(i:i)=' '
        endif
      enddo
      call symm1(filesymm,spg)
    case('TYPE'); read(line,*)key,ntype
      if (ntype.lt.1) then
        close(12)
        stop 'There must be at least 1 atom type!'
      endif
      do i= 1,ntype
        getfc: do
          read(12,'(a)')line
          call nocomment(line)
          if (len_trim(line).eq.0) cycle getfc
          exit getfc
        enddo getfc
        read(line,*, iostat = iostatus)ii,element(ii),fc1(ii),fc2(ii),fc3(ii),fc4(ii),fc5(ii)
        if (iostatus.ne.0) then
          write(0,*)'Error on reading atom types!'
          close(12)
          stop
        endif
        call checkcost(fc1(i))
        if (fc1(i).lt.0) then
          write(0,*)'Unknown expression type for connectivity: ',i,atom(i)
          close(12)
          stop
        endif
        if (nmap.gt.0) then
          do j= 1, nmap
            getfd: do
              read(12,'(a)')line
              call nocomment(line)
              if (len_trim(line).eq.0) cycle getfd
              exit getfd
            enddo getfd
            read(line,*)fd1(i,j),fd2(i,j),fd3(i,j),fd4(i,j),fd5(i,j)
            if (iostatus.ne.0) then
              write(0,*)'Error on reading density restraint for atom type ',i,' in map ',j
              close(12)
              stop
            endif
            call checkcost(fd1(i,j))
            if (fd1(i,j).lt.0) then
              write(0,*)'Unknown expression type for density: ',i,atom(i),j
              close(12)
              stop
            endif
          enddo
        endif
      enddo
    case('ENVI'); read(line,*,iostat = iostatus)key,enva,envb,envc
      if (iostatus.ne.0) then
        write(0,*)'Error on reading the maximum distances for atom pairs'
        close(12)
        stop
      endif
    case('BOND'); read(line,*)key,nfb
      if (nfb.gt.0) then
        do i= 1, nfb
          getfb: do
            read(12,'(a)')line
            call nocomment(line)
            if (len_trim(line).eq.0) cycle getfb
            exit getfb
          enddo getfb
          read(line,*,iostat = iostatus)m,n,dtmax(m,n),fb1(m,n),fb2(m,n),fb3(m,n),fb4(m,n),fb5(m,n)
          if (iostatus.ne.0) then
            write(0,*)'Error on reading bonding restrains for: ',m,n
            close(12)
            stop
          endif
          call checkcost(fb1(m,n))
          if (fb1(m,n).lt.0) then
            write(0,*)'Unknown expression type for bond: ',m,n
            close(12)
            stop
          endif
          dtmax(n,m)=dtmax(m,n)
          fb1(n,m)=fb1(m,n)
          fb2(n,m)=fb2(m,n)
          fb3(n,m)=fb3(m,n)
          fb4(n,m)=fb4(m,n)
          fb5(n,m)=fb5(m,n)
          id12type(m,n)=i
          id12type(n,m)=i
          named12type(1,i)=m
          named12type(2,i)=n
        enddo
      endif
    case('D1_3'); read(line,*)key,nfu
      if (nfu.gt.0) then
        do i= 1,nfu
          getfu: do
            read(12,'(a)')line
            call nocomment(line)
            if (len_trim(line).eq.0) cycle getfu
            exit getfu
          enddo getfu
          read(line,*, iostat = iostatus)l,m,n,fu1(l,m,n),fu2(l,m,n),fu3(l,m,n),fu4(l,m,n),fu5(l,m,n)
          if (iostatus.ne.0) then
            write(0,*)'Error on reading 1-3 distance restrains for: ',l,m,n
            close(12)
            stop
          endif
          call checkcost(fu1(l,m,n))
          if (fu1(l,m,n).lt.0) then
            write(0,*)'Unknown expression type for 1-3 distance: ',l,m,n
            stop
          endif
          fu1(n,m,l)=fu1(l,m,n)
          fu2(n,m,l)=fu2(l,m,n)
          fu3(n,m,l)=fu3(l,m,n)
          fu4(n,m,l)=fu4(l,m,n)
          fu5(n,m,l)=fu5(l,m,n)
          id13type(l,m,n)=i
          id13type(n,m,l)=i
          named13type(1,i)=l
          named13type(2,i)=m
          named13type(3,i)=n
        enddo
      endif
    case('A1_3'); read(line,*)key,nfa
      if (nfa.gt.0) then
        do i=1,nfa
          getfa: do
            read(12,'(a)')line
            call nocomment(line)
            if (len_trim(line).eq.0) cycle getfa
            exit getfa
          enddo getfa
          read(line,*, iostat = iostatus)l,m,n,fa1(l,m,n),fa2(l,m,n),fa3(l,m,n),fa4(l,m,n),fa5(l,m,n)
          if (iostatus.ne.0) then
            write(0,*)'Error on reading bonding restrains for: ',l,m,n
            close(12)
            stop
          endif
          call checkcost(fa1(l,m,n))
          if (fa1(l,m,n).lt.0) then
            write(0,*)'Unknown expression type for angle: ',l,m,n
            stop
          endif
          fa1(n,m,l)=fa1(l,m,n)
          fa2(n,m,l)=fa2(l,m,n)
          fa3(n,m,l)=fa3(l,m,n)
          fa4(n,m,l)=fa4(l,m,n)
          fa5(n,m,l)=fa5(l,m,n)
          ia13type(l,m,n)=i
          ia13type(n,m,l)=i
          namea13type(1,i)=l
          namea13type(2,i)=m
          namea13type(3,i)=n
        enddo
      endif
    case('HKLF'); read(line,*,iostat=iostatus)key,nhkl,wcost5
      if (iostatus.ne.0) then
        write(0,*)' Error on reading number and weight of structure factors!'
        close (12)
        stop
      endif
      if (nhkl.lt.2) write(0,*)' Warning! Cost on reflections will be ignored!'
      fomax=0.000001
      weightsum=0
      do i= 1,nhkl
        getfhkl: do
          read(12,'(a)')line
          call nocomment(line)
          if (len_trim(line).eq.0) cycle getfhkl
          exit getfhkl
        enddo getfhkl
        read(line,*,iostat=iostatus)h0(i),k0(i),l0(i),fo(i),weight(i)
        if (weight(i).lt.0) then
          if (np(1).lt.1) call symm1(filesymm,spg)
          call hklweight(h0(i),k0(i),l0(i),i)
        endif
        weightsum=weightsum+weight(i)
        if (fo(i).gt.fomax) fomax=fo(i)
      enddo
    case('W3MR'); read(line,*)key,w3mr
    case('UNIQ'); read(line,*)key,nuniq
      if (nuniq.lt.1) then
        write(0,*)'Input error! At least 1 atom is needed!'
        close(12)
        stop
      endif
      do i= 1,nuniq
        getuniq: do
          read(12,'(a)')line
          call nocomment(line)
          if (len_trim(line).eq.0) cycle getuniq
          exit getuniq
        enddo getuniq
        read(line,*,iostat=iostatus)atom(i),iatom(i),wyck1(i),xini(i),yini(i),zini(i),xdmax(i),ydmax(i),zdmax(i)
        if (xdmax(i).lt.0.001 .and. ydmax(i).lt.0.001 .and. zdmax(i).lt.0.001) fixatom(i)=.true.
      enddo
    case('FWYC'); read(line,*)key,nforb
      do i=1,nforb
        getforbid: do
          read(12,'(a)')line
          call nocomment(line)
          if (len_trim(line).eq.0) cycle getforbid
          exit getforbid
        enddo getforbid
        read(line,*,iostat=iostatus)j,(forb(k,j), k=1,27)
      enddo
    case('NWYC'); read(line,*)key,nnwyc
      if (nnwyc.gt.27) then
        write(0,*)'Too many wyckoff positions for NWYC!'
        close(12)
        stop
      endif
      do i=1,nnwyc
        getnwyc: do
          read(12,'(a)')line
          call nocomment(line)
          if (len_trim(line).eq.0) cycle getnwyc
          exit getnwyc
        enddo getnwyc
        read(line,*,iostat=iostatus)wyckn(i),nwyck1(i),nwyck2(i)
        if (nwyck1(i).gt.nwyck2(i)) call swapi(nwyck1(i),nwyck2(i))
      enddo
    case('MWYC'); read(line,*)key,nform
      do i= 1,nform
        getform: do
          read(12,'(a)')line
          call nocomment(line)
          if (len_trim(line).eq.0) cycle getform
          exit getform
        enddo getform
        read(line,*,iostat=iostatus)vform1(i),vform2(i),(j,cform(j,i), k=1,nuniq)
        if (vform1(i).gt.vform2(i)) then
          k=vform1(i); vform1(i)=vform2(i); vform2(i)=k
        endif
      enddo
    case('NCYC'); read(line,*)key,ncycle
    case('TEMP'); read(line,*)key,nstage
      do i= 1,nstage
        getstage: do
          read(12,'(a)')line
          call nocomment(line)
          if (len_trim(line).eq.0) cycle getstage
          exit getstage
        enddo getstage
        read(line,*,iostat = iostatus)t(i),deltax(i),deltay(i),deltaz(i),ntry(i),rswap(i)
        if (iostatus.ne.0) then
          write(0,*)'Error on reading parallel stages!'
          close(12)
          stop
        endif
      enddo
    case('STEP'); read(line,*,iostat=iostatus)key,ntrial,nconverge,ntrialbad,costbad
    case('SEED'); read(line,*)key,i
      if (i.ne.0) then
        read(line,*,iostat = iostatus)key,(seed(i),i=1,nseed)
        if (iostatus.ne.0) then
          write(0,*)'Error on reading random seeds'
          close(12)
          stop
        endif
      endif
    case('PRNT'); read(line,*)key,nprnt
    case('SAVE'); read(line,*)key,nsave
    case('END '); exit readinput
    case('    '); cycle readinput
    case default
      write(0,*)'Unknown keyword: ',key
      close(12)
      stop
  end select
enddo readinput
close(12)



if (nprnt.gt.0) write(0,'(x,a)')title
if (defout) then
  fileout=filein(1:iindex)//fileout
  open(unit=13,file=trim(fileout),status= 'unknown')
  else
  write(0,*)'Output file not defined!'
  stop
endif
if (defcsq) then
  filecsq=filein(1:iindex)//filecsq
  open(unit=15,file=trim(filecsq),status= 'unknown')
endif
write(13,*)'#########################################################################'
write(13,*)'#                  Framework Generator (v4.2_20120802)                  #'
write(13,*)'#                                                                       #'
write(13,*)'#                       Yi Li  (yili@jlu.edu.cn)                        #'
write(13,*)'# State Key Laboratory of Inorganic Synthesis and Preparative Chemistry #'
write(13,*)'#   Jilin University, Qianjin Street 2699, Changchun 130012, China PR   #'
write(13,*)'#########################################################################'
if (len_trim(title).lt.0) write(13,'(/,x,a,/)')title
write(13,'(2a)')'Instruction file:     ',filein
if (deflst) write(13,'(2a)')'Output summary file:  ',filelst
if (defcsq) write(13,'(2a)')'CSQ file:             ',filecsq
if (deflog) write(13,'(2a)')'Log file:             ',filelog
if (defread) write(13,'(2a)')'Wyckoff input:        ',fileread
if (defwyck) write(13,'(2a)')'Wyckoff output:       ',filewyck

write(13,'(2a)')'Space group file:     ',filesymm

if (nhkl.ge.2) then
  write(13,'(2a)')'Scattering factors:   ',filesfac
  call getsfac(ntype,element,nhkl,h0,k0,l0,ds,filesfac,f)
endif
if (nmap.gt.0) then
  write(13,'(a)')' Density maps:'
  do i= 1,nmap
    write(13,'(i2,3x,2a,2x,i9,a)')i,denmap(i),' (',ng(i),' grids)'
  enddo
endif
write(13,'(/,a,6(2x,f9.5))')' Unit cell: ',alength,blength,clength,al,be,ga
write(13,'(/,a,3(2x,f6.3))')' Maximum distances for atom pair searching: ',enva,envb,envc
write(13,'(/,2a)')' Space group: ',spg
write(13,'(/,a)')' Restraint function types:'
write(13,'(a)')'  Type  1:  E=(X-A)^2'
write(13,'(a)')'  Type  2:  {X>B} E=(X-A)^2; {X<=B} E=0'
write(13,'(a)')'  Type  3:  {X<B} E=(X-A)^2; {X>=B} E=0'
write(13,'(a)')'  Type  4:  {X<A} E=(X-A)^2; {X>B} E=(X-B)^2; {A<=X<=B} E=0'
write(13,'(a)')'  Type  5:  {X>B} E=(X-A)^2; {X<=A} E=C*(X-A)^2'
write(13,'(a)')'  Type  6:  E=EXP(B*(1.0-X/A))'
write(13,'(a)')'  Type  7:  E=(1-EXP(-B*(X-A)))^2'
write(13,'(a)')'  Type  8:  E=B*EXP(-X/A)-C/X^6'
write(13,'(a)')'  Type  9:  E=(A/X)^12-(A/X)^6'
write(13,'(a)')'  Type 10:  E=(A/X)^B-(A/X)^C'
write(13,'(a)')'  Type 11:  E=(X-A)^B'
write(13,'(a)')'  Type 12:  {X>B} E=(X-A)^C; {X<=B} E=0'
write(13,'(a)')'  Type 13:  {X<B} E=(X-A)^C; {X>=B} E=0'
write(13,'(a)')'  Type 14:  {X<A} E=(X-A)^C; {X>B} E=(X-B)^C; {A<=X<=B} E=0'
write(13,'(/,a)')' Atom type restraints (connectivity and density):'
write(13,'(a)')'  Type  Ftype     A        B        C      Weight'
do i= 1,ntype
  write(13,'(2x,a,3x,i2,x,3f9.3,f10.3)')element(i),fc1(i),fc2(i),fc3(i),fc4(i),fc5(i)
  if (nmap.gt.0) then
    write(13,'(a)')'  Map   Ftype     A        B        C      Weight'
    do j= 1,nmap
      write(13,'(2x,i2,5x,i2,x,3f9.3,f10.3)')j,fd1(i,j),fd2(i,j),fd3(i,j),fd4(i,j),fd5(i,j)
    enddo
  endif
enddo
if (nfb.gt.0) then
  write(13,'(/,a)')' Bond distance restraints:'
  write(13,'(a)')'  Type1  Type2  Dtmax  Ftype     A        B        C      Weight'
  do m= 1,ntype
    do n= m,ntype
      if (fb1(m,n).gt.0) then
        write(13,'(2x,a4,3x,a4,x,f7.3,3x,i2,x,3f9.3,f10.3)')element(m),element(n),dtmax(m,n),fb1(m,n), &
        fb2(m,n),fb3(m,n),fb4(m,n),fb5(m,n)
      endif
    enddo
  enddo
endif
if (nfu.gt.0) then
  write(13,'(/,a)')' 1-3 distance restraints:'
  write(13,'(a)')'  Type1  Type2  Type3  Ftype     A        B        C      Weight'
  do m= 1,ntype
    do l= 1,ntype
      do n= l,ntype
        if (fu1(l,m,n).gt.0) then
          write(13,'(2x,a4,3x,a4,3x,a4,4x,i2,x,3f9.3,f10.3)')element(l),element(m),element(n),fu1(l,m,n), &
          fu2(l,m,n),fu3(l,m,n),fu4(l,m,n),fu5(l,m,n)
        endif
      enddo
    enddo
  enddo
endif
if (nfa.gt.0) then
  write(13,'(/,a)')' Bond angle restraints:'
  write(13,'(a)')'  Type1  Type2  Type3  Ftype     A        B        C      Weight'
  do m= 1,ntype
    do l= 1,ntype
      do n= l,ntype
        if (fa1(l,m,n).gt.0) then
          write(13,'(2x,a4,3x,a4,3x,a4,4x,i2,x,3f9.3,f10.3)')element(l),element(m),element(n),fa1(l,m,n), &
          fa2(l,m,n),fa3(l,m,n),fa4(l,m,n),fa5(l,m,n)
        endif
      enddo
    enddo
  enddo
endif
if (nhkl.ge.2) then
  write(13,'(/,a,f9.3)')' Structure factor restraints: ',wcost5
  write(13,'(a)')'    h   k   l     d        Fo^2    Weight'
  do i= 1, nhkl
    write(13,'(x,3i4,f9.4,x,f10.1,f8.1)')h0(i),k0(i),l0(i),ds(i),fo(i),weight(i)
  enddo
endif
if (w3mr.gt.0) then
  write(13,'(/,a,f10.3)')' 3MR weights: ', w3mr
endif
write(13,'(/,a,i4)')' Number of unique atoms: ', nuniq
write(13,'(a)')'  Atom  Type  Wyck  M      x         y         z      xshift    yshift    zshift'
do i= 1, nuniq
  if (wyck1(i).ne.'?') then
    call symm2(xini(i),yini(i),zini(i),iwyck(i),wyck1(i))
    write(13,'(2x,a,i4,4x,a,x,i4,6f10.6)')atom(i),iatom(i),wyck(iwyck(i)),np(iwyck(i)), &
    xini(i),yini(i),zini(i),xdmax(i),ydmax(i),zdmax(i)
  else
    write(13,'(2x,a,i4,4x,a,5x,6f10.6)')atom(i),iatom(i),wyck1(i),xini(i),yini(i),zini(i),xdmax(i), &
    ydmax(i),zdmax(i)
  endif
enddo

  if (ncycle.gt.0) then
    write(13,*)
    if (nforb.gt.0) then
      do i=1,nuniq
        do j=1,27
          if (forb(j,i).ne.' ') then
            write(13,'(x,29(a,x))') atom(i),' cannot be at positions:',(forb(k,i),k=1,27)
            exit
          endif
        enddo
      enddo
    endif
    if (nform.gt.0) then
      write(13,'(/,a,i5)')' Multiplicity constraints on Wyckoff positions: ',nform
      write(13,'(x,a10,4x,401(a5,x))')'  Min  Max',(atom(i),i=1,nuniq)
      do i=1,nform
        write(13,'(x,2i5,2x,401(i5,x))')vform1(i),vform2(i),(cform(j,i),j=1,nuniq)
      enddo
    endif
    if (nnwyc.gt.0) then
      write(13,'(/,a,i5)')' Constraints on selection of Wyckoff positions: ',nnwyc
      write(13,'(x,a)')'  Wyck  Min  Max'
      do i=1,nnwyc
        write(13,'(6x,a,2i5)')wyckn(i),nwyck1(i),nwyck2(i)
      enddo
    endif
    write(13,'(/,a,2x,i8)')' Number of cycles: ',ncycle
    write(13,'(/,a)')' Temperature scheme: '
    write(13,'(a)')'       T          Deltax      Deltay      Deltaz      Nprop     Rswap'
    do i=1,nstage
      write(13,'(4f12.5,i9,f12.5)')t(i),deltax(i),deltay(i),deltaz(i),ntry(i),rswap(i)
    enddo
    write(13,'(/,a,i12,/)')' Number of trial moves in each cycle: ',ntrial
    if (nconverge.gt.0 .and. nconverge.le.ntrial) then
      write(13,'(a,i12,a,f12.6)')' Cycle will be terminated if the lowest cost value does not change for ', &
      nconverge,' steps'
    endif
    if (ntrialbad.gt.0 .and. ntrialbad.le.ntrial) then
      write(13,'(a,i12,a,f12.6)')' Cycle will be terminated at step ',ntrialbad, &
      ' if the lowest cost value is larger than ',costbad
    endif
    if (seed(1).eq.0) then
      seed = clock+37 * (/ (i-1, i= 1, nseed) /)
    endif
    call random_seed(put=seed)
    write(13,'(/,a,99i15)')' Random seed: ',(seed(i),i= 1,nseed)
    if (nprnt.gt.0) write(13,'(/,a,i12,a)')' Results will be printed on the screen for every',nprnt,' steps.'
    if (nsave.gt.0 .and. deflog) then
      filelog=filein(1:iindex)//filelog
      write(13,'(/,a,i12,a)')' Results will be saved in the log file for every',nsave,' steps.'
      open(unit=16,file=trim(filelog))
    endif
  endif


call date_and_time(date=datejob1,time=timejob1)


! single point calculation


if (ncycle.eq.0) then

  call geti(nuniq,ntall,np,iwyck,ip,ipp)
  do i= 1,nuniq
    if (iwyck(i).lt.1) then
      write(0,*)'The wyckoff position for ',atom(i),' is not known!'
      stop
    endif
    call symm3(i,xini(i),yini(i),zini(i),ip,x22,y22,z22,iwyck,0)
  enddo
  do i= 1,nuniq
    call envi(i,x22,y22,z22,ip,ipp,ntall,ncon2,bond2,dist2,0)
  enddo
  write(13,'(/,/,a)')' Bonding environment:'
  do i= 1,nuniq
    write(13,'(/,x,a,i3,a)')atom(i),ncon2(i,0),' neighbors'
    do j= 1,ncon2(i,0)
      write(13,'(2x,a,x,a,4i4,x,f11.6)')atom(i),atom(ipp(bond2(4,j,i,0))),bond2(4,j,i,0)-ip(1,ipp(bond2(4,j,i,0)))+1, &
      bond2(1,j,i,0),bond2(2,j,i,0),bond2(3,j,i,0),dist2(j,i,0)
      nd12type(id12type(iatom(i),iatom(ipp(bond2(4,j,i,0)))))=nd12type(id12type(iatom(i),iatom(ipp(bond2(4,j,i,0)))))+1
      d12type(nd12type(id12type(iatom(i),iatom(ipp(bond2(4,j,i,0))))),id12type(iatom(i),iatom(ipp(bond2(4,j,i,0)))))=dist2(j,i,0)
      nd12(nd12type(id12type(iatom(i),iatom(ipp(bond2(4,j,i,0))))),id12type(iatom(i),iatom(ipp(bond2(4,j,i,0)))))=np(iwyck(i))
    enddo
  enddo
  write(13,'(/,/,a)')' Bond angles:'
  do i= 1,nuniq
    if (ncon2(i,0).ge.2) then
      write(13,'(/,x,a,i3,a)')atom(i),ncon2(i,0)*(ncon2(i,0)-1)/2,' angles'
      do j= 1,ncon2(i,0)-1
        do k= j+1,ncon2(i,0)
          j1=bond2(1,j,i,0)
          j2=bond2(2,j,i,0)
          j3=bond2(3,j,i,0)
          j4=bond2(4,j,i,0)
          j5=ipp(bond2(4,j,i,0))
          k1=bond2(1,k,i,0)
          k2=bond2(2,k,i,0)
          k3=bond2(3,k,i,0)
          k4=bond2(4,k,i,0)
          k5=ipp(bond2(4,k,i,0))
          d=getdist(x22(j4,0)+j1,y22(j4,0)+j2,z22(j4,0)+j3,x22(k4,0)+k1,y22(k4,0)+k2,z22(k4,0)+k3)
          call angle(dist2(j,i,0),dist2(k,i,0),d,angtmp)
          write(13,'(2x,a,2(x,a),x,2f11.6)')atom(j5),atom(i),atom(k5),d,angtmp
          nd13type(id13type(iatom(j5),iatom(i),iatom(k5)))=nd13type(id13type(iatom(j5),iatom(i),iatom(k5)))+1
          d13type(nd13type(id13type(iatom(j5),iatom(i),iatom(k5))),id13type(iatom(j5),iatom(i),iatom(k5)))=d
          nd13(nd13type(id13type(iatom(j5),iatom(i),iatom(k5))),id13type(iatom(j5),iatom(i),iatom(k5)))=np(iwyck(i))
          na13type(ia13type(iatom(j5),iatom(i),iatom(k5)))=na13type(ia13type(iatom(j5),iatom(i),iatom(k5)))+1
          a13type(na13type(ia13type(iatom(j5),iatom(i),iatom(k5))),ia13type(iatom(j5),iatom(i),iatom(k5)))=angtmp
          na13(na13type(ia13type(iatom(j5),iatom(i),iatom(k5))),ia13type(iatom(j5),iatom(i),iatom(k5)))=np(iwyck(i))
        enddo
      enddo
    endif
  enddo
  write(13,'(/,/,a)')' Statistics:'
  if (nfb.gt.0) then
    write(13,'(/,a,i3)')'  1-2 distances: ',nfb
    write(13,'(a)')'  Type1 Type2   N     Min        Max        Mean       Std'
  endif
  do i=1,nfb
    d12min=99999
    d12max=0
    d12mean=0
    nd12total=0
    d12std=0
    if (nd12type(i).gt.0) then
      do j=1,nd12type(i)
        if (d12type(j,i).lt.d12min) d12min=d12type(j,i)
        if (d12type(j,i).gt.d12max) d12max=d12type(j,i)
        d12mean=d12mean+d12type(j,i)*nd12(j,i)
        nd12total=nd12total+nd12(j,i)
      enddo
      d12mean=d12mean/nd12total
      do j=1,nd12type(i)
        d12std=d12std+((d12type(j,i)-d12mean)**2)*nd12(j,i)
      enddo
      d12std=sqrt(d12std/nd12total)
    endif
    write(13,'(2(2x,a),i5,4f11.6)')element(named12type(1,i)),element(named12type(2,i)),nd12total/2, &
    d12min,d12max,d12mean,d12std
  enddo
  if (nfu.gt.0) then
    write(13,'(/,a,i3)')'  1-3 distances: ',nfu
    write(13,'(a)')'  Type1 Type2 Type3   N     Min        Max        Mean       Std'
  endif
  do i=1,nfu
    d13min=99999
    d13max=0
    d13mean=0
    d13std=0
    nd13total=0
    if (nd13type(i).gt.0) then
      do j=1,nd13type(i)
        if (d13type(j,i).lt.d13min) d13min=d13type(j,i)
        if (d13type(j,i).gt.d13max) d13max=d13type(j,i)
        d13mean=d13mean+d13type(j,i)*nd13(j,i)
        nd13total=nd13total+nd13(j,i)
      enddo
      d13mean=d13mean/nd13total
      do j=1,nd13type(i)
        d13std=d13std+((d13type(j,i)-d13mean)**2)*nd13(j,i)
      enddo
      d13std=sqrt(d13std/nd13total)
    endif
    write(13,'(3(2x,a),i5,4f11.6)')element(named13type(1,i)),element(named13type(2,i)), &
    element(named13type(3,i)),nd13total,d13min,d13max,d13mean,d13std
  enddo
  if (nfa.gt.0) then
    write(13,'(/,a,i3)')'  1-3 angles: ',nfa
    write(13,'(a)')'  Type1 Type2 Type3   N     Min        Max        Mean       Std'
  endif
  do i=1,nfa
    a13min=99999
    a13max=0
    a13mean=0
    a13std=0
    na13total=0
    if (na13type(i).gt.0) then
      do j=1,na13type(i)
        if (a13type(j,i).lt.a13min) a13min=a13type(j,i)
        if (a13type(j,i).gt.a13max) a13max=a13type(j,i)
        a13mean=a13mean+a13type(j,i)*na13(j,i)
        na13total=na13total+na13(j,i)
      enddo
      a13mean=a13mean/na13total
      do j=1,na13type(i)
        a13std=a13std+((a13type(j,i)-a13mean)**2)*na13(j,i)
      enddo
      a13std=sqrt(a13std/na13total)
    endif
    write(13,'(3(2x,a),i5,4f11.6)')element(namea13type(1,i)),element(namea13type(2,i)), &
    element(namea13type(3,i)),na13total,a13min,a13max,a13mean,a13std
  enddo

  ! get current cost value

  edall= 0
  if (nmap.gt.0) then
    do i=1,nuniq
      call getdens(i,x22,y22,z22,ip,nmap,dens2,dens0,0)
      call cost1(i,ip,nmap,dens2,ed2(i,0),0)
      edall=edall+ed2(i,0)
    enddo
    edall=edall/ntall
  endif
  eball= 0
  do i= 1,nuniq
    call cost2(i,ip,ipp,ncon2,dist2,bond2,eb2(i,0),0)
    eball=eball+eb2(i,0)
  enddo
  eball=eball/ntall
  ecall= 0
  do i= 1,nuniq
    call cost3(i,ip,ncon2,ec2(i,0),0)
    ecall=ecall+ec2(i,0)
  enddo
  ecall=ecall/ntall
  euall= 0
  eaall= 0
  e3all= 0
  do i= 1,nuniq
    call cost4(i,ip,x22,y22,z22,ipp,ncon2,dist2,bond2,eu2(i,0),ea2(i,0),w3mr,e32(i,0),0)
    euall=euall+eu2(i,0)
    eaall=eaall+ea2(i,0)
    e3all=e3all+e32(i,0)
  enddo
  euall=euall/ntall
  eaall=eaall/ntall

  if (nhkl.ge.2) then
    do i= 1,nuniq
      call getf0(i,x22,y22,z22,ip,nhkl,h0,k0,l0,f,f02,0)
    enddo
    call getf(nuniq,iwyck,nhkl,f02,f2,0)
    call cost5(nhkl,f2,ehkl,0)
    write(13,'(/,a)')' Calculated structure factors:'
    write(13,'(a)')'    h   k   l        d      RE      IM      Fc^2      Fo^2'
    do i= 1,nhkl
      write(13,'(x,3i4,f9.4,2f8.1,2f11.1)')h0(i),k0(i),l0(i),ds(i),f2(1,i,0),f2(2,i,0),f2(3,i,0),fo(i)
    enddo
  endif
  eall=edall+eball+ecall+euall+eaall+e3all+ehkl
  write(13,'(/,/,a)')'  Costs:'
  write(13,'(/,a)')'     Edens     Ebond     Econn      Ed13      Ea13      E3mr      Ehkl    Etotal'
  write(13,'(8f10.4)')edall,eball,ecall,euall,eaall,e3all,ehkl,eall
  if (defcsq) then
    write(0,*)'Calculating CSQs...'
    call getcsq(x22,y22,z22,nuniq,ntall,iwyck,ip,ipp,ncon2,bond2,ncs,0)
    write(15,'(a)')repeat('#',45)
    line=repeat(' ',512)
    write(line,'(a,i4,a,i5,a,f7.3)')trim(adjustl(fileout))//': ',nuniq,'/  ',ntall,' Cost= ',eall
    call oneblank(line)
    write(15,'(a)')trim(adjustl(line))
    write(15,'(2i4)')nuniq,nshellmax
    do i= 1,nuniq
      line=repeat(' ',512)
      write(line,'(a,12i5)')atom(i),(ncs(j,i),j=1,nshellmax)
      call oneblank(line)
      write(15,'(a)')trim(adjustl(line))
    enddo
    write(0,'(a)')' CSQs calculated successfully.'
  endif
  if (deflst) then
    filelst=filein(1:iindex)//filelst
    open(unit=14,file=trim(filelst),status='unknown')
    write(14,'(a)')'     Edens     Ebond     Econn      Ed13      Ea13      E3mr      Ehkl    Etotal'
    write(14,'(8f10.3)')edall,eball,ecall,euall,eaall,e3all,ehkl,eall
  endif
  call date_and_time(date=datejob2,time=timejob2)
  write(13,*)
  write(13,'(/,/,a)')' Job completed!'
  write(13,'(12a)')' This job started at ',datejob1(1:4),'-',datejob1(5:6),'-',datejob1(7:8),' ', &
  timejob1(1:2),':',timejob1(3:4),':',timejob1(5:6)
  write(13,'(12a)')' This job ended at ',datejob2(1:4),'-',datejob2(5:6),'-',datejob2(7:8),' ', &
  timejob2(1:2),':',timejob2(3:4),':',timejob2(5:6)
  close(13)
  if (deflst) close(14)
  if (defcsq) close(15)
  write(0,*)
  write(0,*)' Done!'
  write(0,*)
  stop

endif


! start cycles


if (.not.deflst) then
  write(0,*)'List file not defined!'
  stop
endif
if (.not.defcsq) then
  write(0,*)'CSQ file not defined!'
  stop
endif
open(unit=15,file=trim(filecsq),status= 'unknown')
filelst=filein(1:iindex)//filelst
open(unit=14,file=trim(filelst),status='unknown')
write(14,'(a)')'   Cycle Uniq  All     Edens     Ebond     Econn      Ed13      Ea13      E3mr      Ehkl    Etotal'
if (defwyck) then
  filewyck=filein(1:iindex)//filewyck
  open(unit=17,file=trim(filewyck),status='unknown')
endif


docycle: do icycle= 1, ncycle

  call date_and_time(date=datecyc1,time=timecyc1)
  if (nprnt.gt.0) write(0,'(/,/,a,i10)')'CYCLE ',icycle
  if (nsave.gt.0 .and. deflog)  write(16,'(/,/,a,i10)')'CYCLE ',icycle
  iconverge=0

  !    get initial configuration


  if (defread) then
    fileread=filein(1:iindex)//fileread
    inquire(unit=19,opened=isopen)
    if (.not.isopen) open(unit=19,file=trim(fileread),status='old')
    read(19,*,iostat=iostatus)(wyck1(i),i=1,nuniq)
    if (iostatus.lt.0) then
      rewind(19)
      read(19,*,iostat=iostatus)(wyck1(i),i=1,nuniq)
    endif
    nuniq1=0
    iwyck1=0
    do i=1,nuniq
      do j=1,27
        if (wyck(j).eq.wyck1(i)) then
          iwyck1(i)=j
          nuniq1=nuniq1+1
          exit
        endif
      enddo
    enddo
    call geti(nuniq,ntall,np,iwyck1,ip,ipp)
  else
    checkwyck: do
      iwyck1=iwyck
      do i= 1,nuniq
        if (wyck1(i).eq.'?') then
          nospecial: do
            call random_number(symtmp)
            iwyck1(i)=int((nsym+1)*symtmp)
            if (iwyck1(i).gt.0) then
              do j=1,27
                if (wyck(iwyck1(i)).eq.forb(j,i)) cycle nospecial
              enddo
              if (i.ge.2 .and. ispecial(iwyck1(i)).gt.0) then
                do j= 1,i-1
                  if (iwyck1(i).eq.iwyck1(j)) cycle nospecial
                enddo
              endif
            endif
            exit nospecial
          enddo nospecial
        endif
      enddo

      nuniq1=nuniq
      do i=1,nuniq
        if (iwyck1(i).eq.0) then
          nuniq1=nuniq1-1
        endif
      enddo
      if (nuniq1.lt.1) cycle checkwyck

      call geti(nuniq,ntall,np,iwyck1,ip,ipp)
      if (nform.gt.0) then
        do i= 1,nform
          tmp=0
          do j= 1,nuniq
            if (iwyck1(j).eq.0) cycle
            tmp=tmp+cform(j,i)*np(iwyck1(j))
          enddo
          if (tmp.lt.vform1(i).or.tmp.gt.vform2(i)) cycle checkwyck
        enddo
      endif

      if (nnwyc.gt.0) then
        do i=1,nnwyc
          nwyck=0
          do j=1,nuniq
            if (iwyck1(j).eq.0) cycle
            if (wyck(iwyck1(j)).eq.wyckn(i)) nwyck=nwyck+1
          enddo
          if (nwyck.lt.nwyck1(i).or.nwyck.gt.nwyck2(i)) cycle checkwyck
        enddo
      endif
      exit checkwyck
    enddo checkwyck
  endif

  ebst= 99999999999.9

  do ii= 1, nstage
    istage(ii)=ii

    do i=1,nuniq
      if (iwyck1(i).eq.0) cycle
      if (xdmax(i).gt.0.499) then
        CALL RANDOM_NUMBER(x1(i,ii))
      else
        x1(i,ii)=xini(i)
      endif
      if (ydmax(i).gt.0.499) then
        CALL RANDOM_NUMBER(y1(i,ii))
      else
        y1(i,ii)=yini(i)
      endif
      if (zdmax(i).gt.0.499) then
        CALL RANDOM_NUMBER(z1(i,ii))
      else
        z1(i,ii)=zini(i)
      endif
      call symm3(i,x1(i,ii),y1(i,ii),z1(i,ii),ip,x22,y22,z22,iwyck1,0)
      do j=ip(1,i),ip(2,i)
        x11(j,ii)=x22(j,0)
        y11(j,ii)=y22(j,0)
        z11(j,ii)=z22(j,0)
      enddo
    enddo

    do i= 1,nuniq
      if (iwyck1(i).eq.0) cycle
      call envi(i,x22,y22,z22,ip,ipp,ntall,ncon2,bond2,dist2,0)
      ncon1(i,ii)=ncon2(i,0)
      do j= 1,ncon2(i,0)
        dist1(j,i,ii)=dist2(j,i,0)
        bond1(1,j,i,ii)=bond2(1,j,i,0)
        bond1(2,j,i,ii)=bond2(2,j,i,0)
        bond1(3,j,i,ii)=bond2(3,j,i,0)
        bond1(4,j,i,ii)=bond2(4,j,i,0)
      enddo
    enddo
    edens1(ii)=0
    ebond1(ii)=0
    econ1(ii)=0
    eub1(ii)=0
    eang1(ii)=0
    e3mr1(ii)=0
    ef1(ii)=0
    do i= 1,nuniq
      if (iwyck1(i).eq.0) cycle
      if (nmap.gt.0) then
        call getdens(i,x22,y22,z22,ip,nmap,dens2,dens0,0)
        do j= 1,nmap
          do k= ip(1,i),ip(2,i)
            dens1(k,j,ii)=dens2(k,j,0)
          enddo
        enddo
        call cost1(i,ip,nmap,dens2,ed2(i,0),0)
        ed1(i,ii)=ed2(i,0)
        edens1(ii)=edens1(ii)+ed1(i,ii)
      endif
      call cost2(i,ip,ipp,ncon2,dist2,bond2,eb2(i,0),0)
      eb1(i,ii)=eb2(i,0)
      ebond1(ii)=ebond1(ii)+eb1(i,ii)
      call cost3(i,ip,ncon2,ec2(i,0),0)
      ec1(i,ii)=ec2(i,0)
      econ1(ii)=econ1(ii)+ec1(i,ii)
      call cost4(i,ip,x22,y22,z22,ipp,ncon2,dist2,bond2,eu2(i,0),ea2(i,0),w3mr,e32(i,0),0)
      eu1(i,ii)=eu2(i,0)
      ea1(i,ii)=ea2(i,0)
      e31(i,ii)=e32(i,0)
      eub1(ii)=eub1(ii)+eu1(i,ii)
      eang1(ii)=eang1(ii)+ea1(i,ii)
      e3mr1(ii)=e3mr1(ii)+e31(i,ii)
    enddo
    edens1(ii)=edens1(ii)/ntall
    ebond1(ii)=ebond1(ii)/ntall
    econ1(ii)=econ1(ii)/ntall
    eub1(ii)=eub1(ii)/ntall
    eang1(ii)=eang1(ii)/ntall

    if (nhkl.ge.2) then
      do i= 1,nuniq
        if (iwyck1(i).eq.0) cycle
        call getf0(i,x22,y22,z22,ip,nhkl,h0,k0,l0,f,f02,0)
        do j= 1,nhkl
          f01(1,j,i,ii)=f02(1,j,i,0)
          f01(2,j,i,ii)=f02(2,j,i,0)
        enddo
      enddo
      call getf(nuniq,iwyck1,nhkl,f02,f2,0)
      do j= 1,nhkl
        f1(1,j,ii)=f2(1,j,0)
        f1(2,j,ii)=f2(2,j,0)
        f1(3,j,ii)=f2(3,j,0)
      enddo
      call cost5(nhkl,f2,ef1(ii),0)
    endif

    e1(ii)=edens1(ii)+ebond1(ii)+econ1(ii)+eub1(ii)+eang1(ii)+e3mr1(ii)+ef1(ii)
    if (e1(ii).lt.ebst) then
      ebst=e1(ii)
      edensbst=edens1(ii)
      ebondbst=ebond1(ii)
      econbst=econ1(ii)
      eubbst=eub1(ii)
      eangbst=eang1(ii)
      e3mrbst=e3mr1(ii)
      efbst=ef1(ii)
      do i= 1,nuniq
        if (iwyck1(i).eq.0) cycle
        xbst(i)=x1(i,ii)
        ybst(i)=y1(i,ii)
        zbst(i)=z1(i,ii)
      enddo
    endif
  enddo


  naccept= 0
  nswap= 0


  dotrial: do itrial= 1, ntrial

    iconverge=iconverge+1

    if (nstage.gt.1) then
      j=nstage

      doswap: do
        if (j.ge.2) then
          reject1= 1
          call random_number(tmp)
          if (tmp.lt.rswap(j)) then
            call random_number(tmp8)
            call swap(e1(j-1),e1(j),t(j-1),t(j),tmp8,reject1)
            if (reject1.lt.0) then
              call swapi(istage(j),istage(j-1))
              call swap4(edens1(j),edens1(j-1))
              call swap4(ebond1(j),ebond1(j-1))
              call swap4(econ1(j),econ1(j-1))
              call swap4(eub1(j),eub1(j-1))
              call swap4(eang1(j),eang1(j-1))
              call swap4(e3mr1(j),e3mr1(j-1))
              call swap4(ef1(j),ef1(j-1))
              call swap8(e1(j),e1(j-1))
              if (nhkl.ge.2) then
                do k= 1,nhkl
                  call swap4(f1(1,k,j),f1(1,k,j-1))
                  call swap4(f1(2,k,j),f1(2,k,j-1))
                  call swap4(f1(3,k,j),f1(3,k,j-1))
                  do i= 1,nuniq
                    if (iwyck1(i).eq.0) cycle
                    call swap4(f01(1,k,i,j),f01(1,k,i,j-1))
                    call swap4(f01(2,k,i,j),f01(2,k,i,j-1))
                  enddo
                enddo
              endif
              do i= 1,nuniq
              if (iwyck1(i).eq.0) cycle
              call swap4(x1(i,j),x1(i,j-1))
              call swap4(y1(i,j),y1(i,j-1))
              call swap4(z1(i,j),z1(i,j-1))
              call swap4(ed1(i,j),ed1(i,j-1))
              call swap4(eb1(i,j),eb1(i,j-1))
              call swap4(ec1(i,j),ec1(i,j-1))
              call swap4(eu1(i,j),eu1(i,j-1))
              call swap4(ea1(i,j),ea1(i,j-1))
              call swap4(e31(i,j),e31(i,j-1))
              do k= 1,max(ncon1(i,j),ncon1(i,j-1))
                call swap4(dist1(k,i,j),dist1(k,i,j-1))
                call swapi(bond1(1,k,i,j),bond1(1,k,i,j-1))
                call swapi(bond1(2,k,i,j),bond1(2,k,i,j-1))
                call swapi(bond1(3,k,i,j),bond1(3,k,i,j-1))
                call swapi(bond1(4,k,i,j),bond1(4,k,i,j-1))
              enddo
              call swapi(ncon1(i,j),ncon1(i,j-1))
              do k=ip(1,i),ip(2,i)
                call swap4(x11(k,j),x11(k,j-1))
                call swap4(y11(k,j),y11(k,j-1))
                call swap4(z11(k,j),z11(k,j-1))
                do k2= 1,nmap
                  call swap4(dens1(k,k2,j),dens1(k,k2,j-1))
                enddo
              enddo
            enddo
              nswap(j)=nswap(j)+1
              nswap(j-1)=nswap(j-1)+1
            endif
          endif
          if (reject1.lt.0) then
            j=j-2
          else
            j=j-1
          endif
          cycle doswap
        endif
        exit doswap
      enddo doswap

    endif


    dostage: do ii= 1, nstage

      do m= 1, ntry(ii)
        do k= 1, nuniq
          if (iwyck1(k).eq.0) cycle
          do j=ip(1,k),ip(2,k)
            x22(j,m)=x11(j,ii)
            y22(j,m)=y11(j,ii)
            z22(j,m)=z11(j,ii)
            do i= 1, nmap
              dens2(j,i,m)=dens1(j,i,ii)
            enddo
          enddo
          ed2(k,m)=ed1(k,ii)
          eb2(k,m)=eb1(k,ii)
          ec2(k,m)=ec1(k,ii)
          eu2(k,m)=eu1(k,ii)
          ea2(k,m)=ea1(k,ii)
          e32(k,m)=e31(k,ii)
          ncon2(k,m)=ncon1(k,ii)
          do j= 1,ncon1(k,ii)
            dist2(j,k,m)=dist1(j,k,ii)
            bond2(1,j,k,m)=bond1(1,j,k,ii)
            bond2(2,j,k,m)=bond1(2,j,k,ii)
            bond2(3,j,k,m)=bond1(3,j,k,ii)
            bond2(4,j,k,m)=bond1(4,j,k,ii)
          enddo
        enddo
      enddo

      moveatom: do
        call random_number(xmove)
        i=int(nuniq*xmove)+1
        if (fixatom(i)) cycle moveatom
        if (iwyck1(i).eq.0) cycle moveatom
        exit moveatom
      enddo moveatom
      do j= 1, nuniq
        if (iwyck1(j).eq.0) cycle
        iup1(j,ii)= -1
      enddo
      iup1(i,ii)= 1
      do jj= 1, ncon1(i,ii)
        iup1(ipp(bond1(4,jj,i,ii)),ii)= 1
      enddo

      e2min= 9999999999.9

      dotry: do itry= 1, ntry(ii)

        !    getdelta: do
        CALL RANDOM_NUMBER(delta)
        if (xdmax(i).gt.0.499) x2(itry)=x1(i,ii)+(1-2*delta)*deltax(ii)
        if (xdmax(i).gt.0.001 .and. xdmax(i).le.0.499) then
          x2(itry)=x1(i,ii)+(1-2*delta)*deltax(ii)
          dtmp=x2(itry)-xini(i)
          if (abs(dtmp).gt.xdmax(i)) x2(itry)=xini(i)+sign(xdmax(i),dtmp)
        endif
        if (xdmax(i).le.0.001) x2(itry)=xini(i)
        x2(itry)=translate(x2(itry))
        CALL RANDOM_NUMBER(delta)
        if (ydmax(i).gt.0.499) y2(itry)=y1(i,ii)+(1-2*delta)*deltay(ii)
        if (ydmax(i).gt.0.001 .and. ydmax(i).le.0.499) then
          y2(itry)=y1(i,ii)+(1-2*delta)*deltay(ii)
          dtmp=y2(itry)-yini(i)
          if (abs(dtmp).gt.ydmax(i)) y2(itry)=yini(i)+sign(ydmax(i),dtmp)
        endif
        if (ydmax(i).le.0.001) y2(itry)=yini(i)
        y2(itry)=translate(y2(itry))
        CALL RANDOM_NUMBER(delta)
        if (zdmax(i).gt.0.499) z2(itry)=z1(i,ii)+(1-2*delta)*deltaz(ii)
        if (zdmax(i).gt.0.001 .and. zdmax(i).le.0.499) then
          z2(itry)=z1(i,ii)+(1-2*delta)*deltaz(ii)
          dtmp=z2(itry)-zini(i)
          if (abs(dtmp).gt.zdmax(i)) z2(itry)=zini(i)+sign(zdmax(i),dtmp)
        endif
        if (zdmax(i).le.0.001) z2(itry)=zini(i)
        z2(itry)=translate(z2(itry))

        call symm3(i,x2(itry),y2(itry),z2(itry),ip,x22,y22,z22,iwyck1,itry)
        call envi(i,x22,y22,z22,ip,ipp,ntall,ncon2,bond2,dist2,itry)
        do jj = 1, nuniq
          if (iwyck1(jj).eq.0) cycle
          iup2(jj,ii)=-1
        enddo
        do jj= 1, ncon2(i,itry)
          iup2(ipp(bond2(4,jj,i,itry)),ii)= 1
        enddo
        do k= 1, nuniq
          if (iwyck1(k).eq.0) cycle
          if (iup1(k,ii).gt.0 .or. iup2(k,ii).gt.0) then
            if (k.ne.i) then
              call envi2(k,i,x22,y22,z22,ip,ncon2,bond2,dist2,itry)
            endif
          endif
        enddo

        edens2(itry)= 0
        ebond2(itry)= 0
        econ2(itry)= 0
        eub2(itry)= 0
        eang2(itry)= 0
        e3mr2(itry)= 0
        ef2(itry)= 0
        do k= 1,nuniq
          if (iwyck1(k).eq.0) cycle
          if (iup1(k,ii).gt.0 .or. iup2(k,ii).gt.0) then
            if (nmap.gt.0) then
              call getdens(i,x22,y22,z22,ip,nmap,dens2,dens0,itry)
              call cost1(k,ip,nmap,dens2,ed2(k,itry),itry)
            endif
            call cost2(k,ip,ipp,ncon2,dist2,bond2,eb2(k,itry),itry)
            call cost3(k,ip,ncon2,ec2(k,itry),itry)
            call cost4(k,ip,x22,y22,z22,ipp,ncon2,dist2,bond2,eu2(k,itry),ea2(k,itry),w3mr,e32(k,itry),itry)
          endif
          if (nmap.gt.0) then
            edens2(itry)=edens2(itry)+ed2(k,itry)
          endif
          ebond2(itry)=ebond2(itry)+eb2(k,itry)
          econ2(itry)=econ2(itry)+ec2(k,itry)
          eub2(itry)=eub2(itry)+eu2(k,itry)
          eang2(itry)=eang2(itry)+ea2(k,itry)
          e3mr2(itry)=e3mr2(itry)+e32(k,itry)
        enddo
        edens2(itry)=edens2(itry)/ntall
        ebond2(itry)=ebond2(itry)/ntall
        econ2(itry)=econ2(itry)/ntall
        eub2(itry)=eub2(itry)/ntall
        eang2(itry)=eang2(itry)/ntall

        if (nhkl.ge.2) then
          call getf0(i,x22,y22,z22,ip,nhkl,h0,k0,l0,f,f02,itry)
          do j= 1,nhkl
            f2(1,j,itry)=f1(1,j,ii)-f01(1,j,i,ii)+f02(1,j,i,itry)
            f2(2,j,itry)=f1(2,j,ii)-f01(2,j,i,ii)+f02(2,j,i,itry)
            f2(3,j,itry)=f2(1,j,itry)**2+f2(2,j,itry)**2
          enddo
          call cost5(nhkl,f2,ef2(itry),itry)
        endif

        e2(itry)=edens2(itry)+ebond2(itry)+econ2(itry)+eub2(itry)+eang2(itry)+e3mr2(itry)+ef2(itry)

        if (ntry(ii).eq.1) then
          CALL RANDOM_NUMBER(tmp8)
          call metropolis(e1(ii),e2(itry),t(ii),tmp8,reject)
          exit dotry
        endif

        if (e2(itry).lt.e2min) e2min=e2(itry)

      enddo dotry


      if (ntry(ii).ge.2) then
        wn = 0

        do itry= 1, ntry(ii)
          expe(itry)=dexp(-(e2(itry)-e2min)/t(ii))
          wn=wn+expe(itry)
        enddo

        itry = 1

        call random_number(tmp8)
        tmp8 = tmp8 * wn
        p1= 0

        doitry: do
          p2 = p1 + expe(itry)
          if (tmp8.le.p2) exit doitry
          p1=p2
          itry=itry+1
        enddo doitry

        do k= 1,nuniq
          if (iwyck1(k).eq.0) cycle
          do j=ip(1,k),ip(2,k)
            x22(j,0)=x22(j,itry)
            y22(j,0)=y22(j,itry)
            z22(j,0)=z22(j,itry)
            do iii= 1,nmap
              dens2(j,iii,0)=dens2(j,iii,itry)
            enddo
          enddo
          ed2(k,0)=ed2(k,itry)
          eb2(k,0)=eb2(k,itry)
          ec2(k,0)=ec2(k,itry)
          eu2(k,0)=eu2(k,itry)
          ea2(k,0)=ea2(k,itry)
          e32(k,0)=e32(k,itry)
          ncon2(k,0)=ncon2(k,itry)
          do j= 1,ncon2(k,itry)
            dist2(j,k,0)=dist2(j,k,itry)
            bond2(1,j,k,0)=bond2(1,j,k,itry)
            bond2(2,j,k,0)=bond2(2,j,k,itry)
            bond2(3,j,k,0)=bond2(3,j,k,itry)
            bond2(4,j,k,0)=bond2(4,j,k,itry)
          enddo
        enddo

        do jj= 1,nuniq
          if (iwyck1(jj).eq.0) cycle
          iup1(jj,ii)= -1
          iup2(jj,ii)= -1
        enddo

        iup1(i,ii)= 1

        do jj= 1,ncon2(i,itry)
        iup1(ipp(bond2(4,jj,i,itry)),ii)= 1
        enddo

        e3min=e1(ii)
        e3(1)=e1(ii)

        dojtry: do jtry= 2,ntry(ii)

          CALL RANDOM_NUMBER(delta)
          if (xdmax(i).gt.0.499) x2(0)=x2(itry)+(1-2*delta)*deltax(ii)
          if (xdmax(i).gt.0.001 .and. xdmax(i).le.0.499) then
            x2(0)=x2(itry)+(1-2*delta)*deltax(ii)
            dtmp=x2(0)-xini(i)
            if (abs(dtmp).gt.xdmax(i)) x2(0)=xini(i)+sign(xdmax(i),dtmp)
          endif
          if (xdmax(i).le.0.001) x2(0)=xini(i)
          x2(0)=translate(x2(0))
          CALL RANDOM_NUMBER(delta)
          if (ydmax(i).gt.0.499) y2(0)=y2(itry)+(1-2*delta)*deltay(ii)
          if (ydmax(i).gt.0.001 .and. ydmax(i).le.0.499) then
            y2(0)=y2(itry)+(1-2*delta)*deltay(ii)
            dtmp=y2(0)-yini(i)
            if (abs(dtmp).gt.ydmax(i)) y2(0)=yini(i)+sign(ydmax(i),dtmp)
          endif
          if (ydmax(i).le.0.001) y2(0)=yini(i)
          y2(0)=translate(y2(0))
          CALL RANDOM_NUMBER(delta)
          if (zdmax(i).gt.0.499) z2(0)=z2(itry)+(1-2*delta)*deltaz(ii)
          if (zdmax(i).gt.0.001 .and. zdmax(i).le.0.499) then
            z2(0)=z2(itry)+(1-2*delta)*deltaz(ii)
            dtmp=z2(0)-zini(i)
            if (abs(dtmp).gt.zdmax(i)) z2(0)=zini(i)+sign(zdmax(i),dtmp)
          endif
          if (zdmax(i).le.0.001) z2(0)=zini(i)
          z2(0)=translate(z2(0))

          call symm3(i,x2(0),y2(0),z2(0),ip,x22,y22,z22,iwyck1,0)
          call envi(i,x22,y22,z22,ip,ipp,ntall,ncon2,bond2,dist2,0)
          do jj= 1,ncon2(i,0)
            iup2(ipp(bond2(4,jj,i,0)),ii)= 1
          enddo
          do k= 1,nuniq
            if (iwyck1(k).eq.0) cycle
            if (iup1(k,ii).gt.0.or.iup2(k,ii).gt.0) then
              if (k.ne.i) call envi2(k,i,x22,y22,z22,ip,ncon2,bond2,dist2,0)
            endif
          enddo

          edens2(0)= 0
          ebond2(0)= 0
          econ2(0)= 0
          eub2(0)= 0
          eang2(0)= 0
          e3mr2(0)= 0
          ef2(0)= 0
          do k= 1,nuniq
            if (iwyck1(k).eq.0) cycle
            if (iup1(k,ii).gt.0 .or. iup2(k,ii).gt.0) then
              if (nmap.gt.0) then
                call getdens(i,x22,y22,z22,ip,nmap,dens2,dens0,0)
                call cost1(k,ip,nmap,dens2,ed2(k,0),0)
                edens2(0)=edens2(0)+ed2(k,0)
              endif
              call cost2(k,ip,ipp,ncon2,dist2,bond2,eb2(k,0),0)
              ebond2(0)=ebond2(0)+eb2(k,0)
              call cost3(k,ip,ncon2,ec2(k,0),0)
              econ2(0)=econ2(0)+ec2(k,0)
              call cost4(k,ip,x22,y22,z22,ipp,ncon2,dist2,bond2,eu2(k,0),ea2(k,0),w3mr,e32(k,0),0)
              eub2(0)=eub2(0)+eu2(k,0)
              eang2(0)=eang2(0)+ea2(k,0)
              e3mr2(0)=e3mr2(0)+e32(k,0)
            else
              if (nmap.gt.0) then
                edens2(0)=edens2(0)+ed2(k,itry)
              endif
              ebond2(0)=ebond2(0)+eb2(k,itry)
              econ2(0)=econ2(0)+ec2(k,itry)
              eub2(0)=eub2(0)+eu2(k,itry)
              eang2(0)=eang2(0)+ea2(k,itry)
              e3mr2(0)=e3mr2(0)+e32(k,itry)
            endif
          enddo
          edens2(0)=edens2(0)/ntall
          ebond2(0)=ebond2(0)/ntall
          econ2(0)=econ2(0)/ntall
          eub2(0)=eub2(0)/ntall
          eang2(0)=eang2(0)/ntall

          if (nhkl.ge.2) then
            call getf0(i,x22,y22,z22,ip,nhkl,h0,k0,l0,f,f02,0)
            do j= 1,nhkl
              f2(1,j,0)=f1(1,j,ii)-f01(1,j,i,ii)+f02(1,j,i,0)
              f2(2,j,0)=f1(2,j,ii)-f01(2,j,i,ii)+f02(2,j,i,0)
              f2(3,j,0)=f2(1,j,0)**2+f2(2,j,0)**2
            enddo
            call cost5(nhkl,f2,ef2(0),0)
          endif

          e3(jtry)=edens2(0)+ebond2(0)+econ2(0)+eub2(0)+eang2(0)+e3mr2(0)+ef2(0)
          if (e3(jtry).lt.e3min) e3min=e3(jtry)

        enddo dojtry

        wo= 0
        do jtry= 1,ntry(ii)
          wo=wo+dexp(-(e3(jtry)-e3min)/t(ii))
        enddo

        CALL RANDOM_NUMBER(tmp8)
        call cbmc(e2min,wn,e3min,wo,t(ii),tmp8,reject)

      endif

      if (reject.lt.0) then
        naccept(ii)=naccept(ii)+1
        edens1(ii)=edens2(itry)
        ebond1(ii)=ebond2(itry)
        econ1(ii)=econ2(itry)
        eub1(ii)=eub2(itry)
        eang1(ii)=eang2(itry)
        e3mr1(ii)=e3mr2(itry)
        ef1(ii)=ef2(itry)
        e1(ii)=e2(itry)
        x1(i,ii)=x2(itry)
        y1(i,ii)=y2(itry)
        z1(i,ii)=z2(itry)
        if (nhkl.ge.2) then
          do k= 1,nhkl
            f1(1,k,ii)=f2(1,k,itry)
            f1(2,k,ii)=f2(2,k,itry)
            f1(3,k,ii)=f2(3,k,itry)
            f01(1,k,i,ii)=f02(1,k,i,itry)
            f01(2,k,i,ii)=f02(2,k,i,itry)
          enddo
        endif
        do j=ip(1,i),ip(2,i)
          x11(j,ii)=x22(j,itry)
          y11(j,ii)=y22(j,itry)
          z11(j,ii)=z22(j,itry)
          do k= 1,nmap
            dens1(j,k,ii)=dens2(j,k,itry)
          enddo
        enddo
        do k= 1,nuniq
          if (iwyck1(k).eq.0) cycle
          ncon1(k,ii)=ncon2(k,itry)
          do j= 1,ncon2(k,itry)
            dist1(j,k,ii)=dist2(j,k,itry)
            bond1(1,j,k,ii)=bond2(1,j,k,itry)
            bond1(2,j,k,ii)=bond2(2,j,k,itry)
            bond1(3,j,k,ii)=bond2(3,j,k,itry)
            bond1(4,j,k,ii)=bond2(4,j,k,itry)
          enddo
          ed1(k,ii)=ed2(k,itry)
          eb1(k,ii)=eb2(k,itry)
          ec1(k,ii)=ec2(k,itry)
          eu1(k,ii)=eu2(k,itry)
          ea1(k,ii)=ea2(k,itry)
          e31(k,ii)=e32(k,itry)
        enddo
      endif


      if (e1(ii).lt.ebst) then
        edensbst=edens1(ii)
        ebondbst=ebond1(ii)
        econbst=econ1(ii)
        eubbst=eub1(ii)
        eangbst=eang1(ii)
        e3mrbst=e3mr1(ii)
        efbst=ef1(ii)
        ebst=e1(ii)
        do j= 1,nuniq
          if (iwyck1(j).eq.0) cycle
          xbst(j)=x1(j,ii)
          ybst(j)=y1(j,ii)
          zbst(j)=z1(j,ii)
        enddo
        iconverge=0
      endif

    enddo dostage


    if (nprnt.gt.0 .and. mod(itrial,nprnt).eq.0) then
      write(0,'(/,a,i8,a,i12,a,f9.3)')' Cycle ',icycle,'      Step ',itrial,'            Ebest',ebst
      write(0,'(a)')'----------------------------------------------------------------'
      write(0,'(a)')'       Temp.     Nswap     Nmove    Rswap    Rmove      E     ID'
      write(0,'(a)')'----------------------------------------------------------------'
      do k= 1,nstage
        write(0,'(f12.5,2i10,3f9.3,i5)')t(k),nswap(k),naccept(k),nswap(k)*1.0/itrial, &
        naccept(k)*1.0/itrial,e1(k),istage(k)
      enddo
      write(0,'(a)')'----------------------------------------------------------------'
    endif
    if (nsave.gt.0 .and. len_trim(filelog).gt.0 .and. mod(itrial,nsave).eq.0) then
      write(16,'(/,a,i8,a,i12,a,f9.3)')' Cycle ',icycle,'      Step ',itrial,'            Ebest',ebst
      write(16,'(a)')'----------------------------------------------------------------'
      write(16,'(a)')'       Temp.     Nswap     Nmove    Rswap    Rmove      E     ID'
      write(16,'(a)')'----------------------------------------------------------------'
      do k= 1,nstage
        write(16,'(f12.5,2i10,3f9.3,i5)')t(k),nswap(k),naccept(k),nswap(k)*1.0/itrial,naccept(k)*1.0/itrial,e1(k),istage(k)
      enddo
      write(16,'(a)')'----------------------------------------------------------------'
    endif

    if (iconverge.eq.nconverge) exit dotrial
    if (itrial.eq.ntrialbad) then
      if (ebst.gt.costbad) exit dotrial
    endif

  enddo dotrial


  if ((tout.lt.0).or.(ebst.le.tout)) then
    line=repeat(' ',512)
    write(line,'(a,i8,a,i4,a,i5,a,f7.3)')'Cycle',icycle,', ',nuniq1,'/  ',ntall,' atoms, Cost= ',ebst
    call oneblank(line)
    write(13,'(/,x,a)')trim(adjustl(line))
    write(13,'(a)')'  Atom  Type Wyck  M        x         y         z'
  endif
  do i= 1,nuniq
    if (iwyck1(i).eq.0) cycle
    if ((tout.lt.0).or.(ebst.le.tout)) write(13,'(2x,a,i4,3x,a,i5,2x,3f10.6)')atom(i),iatom(i), &
    wyck(iwyck1(i)),np(iwyck1(i)),xbst(i),ybst(i),zbst(i)
    call symm3(i,xbst(i),ybst(i),zbst(i),ip,x22,y22,z22,iwyck1,0)
  enddo
  if ((tcsq.lt.0).or.(ebst.le.tcsq)) then
    if (nprnt.gt.0) write(0,*)'Calculating CSQs...'
    write(15,'(a)')repeat('#',45)
    line=repeat(' ',512)
    write(line,'(a,i8,a,i4,a,i5,a,f7.3)')trim(adjustl(fileout))//': Cycle',icycle,', ',nuniq1,'/  ',ntall,' atoms, Cost= ',ebst
    call oneblank(line)
    write(15,'(a)')trim(adjustl(line))
    write(15,'(2i4)')nuniq1,nshellmax
    do i= 1,nuniq
      if (iwyck1(i).eq.0) cycle
      call envi(i,x22,y22,z22,ip,ipp,ntall,ncon2,bond2,dist2,0)
    enddo
    call getcsq(x22,y22,z22,nuniq,ntall,iwyck1,ip,ipp,ncon2,bond2,ncs,0)
    do i= 1,nuniq
      if (iwyck1(i).eq.0) cycle
      line=repeat(' ',512)
      write(line,'(a,12i5)')atom(i),(ncs(j,i),j=1,nshellmax)
      call oneblank(line)
      write(15,'(a)')trim(adjustl(line))
    enddo
    if (nprnt.gt.0) write(0,'(a)')' CSQs calculated successfully.'
  endif
  if ((tlst.lt.0).or.(ebst.le.tlst)) write(14,'(i8,2i5,8f10.3)')icycle,nuniq1,ntall,edensbst,ebondbst, &
  econbst,eubbst,eangbst,e3mrbst,efbst,ebst
  if (len_trim(filewyck).gt.0 .and. (twyck.lt.0 .or. ebst.le.twyck)) then
    do i=1,nuniq
      if (iwyck1(i).eq.0) then
        wyckcode(i)='*'
      else
        wyckcode(i)=wyck(iwyck1(i))
      endif
    enddo
!    write(17,'(i8,2i5,f10.3,300(i3,x,a))')icycle,nuniq1,ntall,ebst,(np(iwyckcode(i)),wyck(iwyckcode(i)),i=1,nuniq1)
    write(17,'(i8,2i5,f10.3,300(x,a))')icycle,nuniq1,ntall,ebst,(wyckcode(i),i=1,nuniq)
  endif
  if (nprnt.gt.0) write(0,'(a,i8,/)')' End of Cycle',icycle
  call date_and_time(date=datecyc2,time=timecyc2)
  if ((tout.lt.0).or.(ebst.le.tout)) then
    write(13,'(/,12a)')' This cycle started at ',datecyc1(1:4),'-',datecyc1(5:6),'-',datecyc1(7:8),' ', &
    timecyc1(1:2),':',timecyc1(3:4),':',timecyc1(5:6)
    write(13,'(12a,/)')' This cycle ended at ',datecyc2(1:4),'-',datecyc2(5:6),'-',datecyc2(7:8),' ', &
    timecyc2(1:2),':',timecyc2(3:4),':',timecyc2(5:6)
  endif


enddo docycle

close(14)
close(16)
inquire(unit=19,opened=isopen)
if (isopen) close(19)
inquire(unit=17,opened=isopen)
if (isopen) close(17)

call date_and_time(date=datejob2,time=timejob2)
write(13,*)
write(13,'(a)')' Job completed!'
write(13,'(12a)')' This job started at ',datejob1(1:4),'-',datejob1(5:6),'-',datejob1(7:8),' ', &
timejob1(1:2),':',timejob1(3:4),':',timejob1(5:6)
write(13,'(12a)')' This job ended at ',datejob2(1:4),'-',datejob2(5:6),'-',datejob2(7:8),' ', &
timejob2(1:2),':',timejob2(3:4),':',timejob2(5:6)
close(13)
close(15)
write(0,'(/,a,/)')' Done!'

end program fg



subroutine metropolis(eold,enew,temperature,tmp8,reject)
real(8) :: eold,enew,tmp8,temperature
if ((eold-enew).ge.0) then
  reject= -1
else
  if (((eold-enew)/temperature).gt.dlog(tmp8)) then
    reject= -1
  else
    reject= 1
  endif
endif
end subroutine metropolis


subroutine cbmc(e2min,wn,e3min,wo,t,tmp8,reject)
real(8) :: e2min,wn,e3min,wo,tmp8,a,t
a=(e3min-e2min)/t+dlog(wn)-dlog(wo)
if (a.gt.dlog(tmp8)) then
  reject= -1
else
  reject= 1
endif
end subroutine cbmc


subroutine swap(ei,ej,ti,tj,tmp8,reject)
real(8) :: ei,ej,ti,tj,a,tmp8
reject= 1
a=(1/ti-1/tj)*(ei-ej)
if (a.ge.0.0) then
  reject= -1
else
  if (a.gt.dlog(tmp8)) reject= -1
endif
end subroutine swap


subroutine getdens(nt,x,y,z,ip,nmap,dens,dens0,ii)
use parameters
!    use atomtype
!    use cell
use grid
real, dimension(ntallmax,0:ntrymax) :: x,y,z,dens0(ngmax,nmapmax),dens(ntallmax,nmapmax,0:ntrymax),den(8),d(8)
integer, dimension(2,ntmax) :: ip

cyclemap: do i= 1,nmap
  aunit= 1.0/na(i)
  bunit= 1.0/nb(i)
  cunit= 1.0/nc(i)
  j=ip(1,nt)
  ix=int(x(j,ii)/aunit)
  iy=int(y(j,ii)/bunit)
  iz=int(z(j,ii)/cunit)
  n=0
  do j3=iz,iz+1
    if (j3.eq.(cmax(i)+1)) then
      k3=cmin(i)
    else
      k3=j3
    endif
    do j2=iy,iy+1
      if (j2.eq.(bmax(i)+1)) then
        k2=bmin(i)
      else
        k2=j2
      endif
      do j1=ix,ix+1
        if (j1.eq.(amax(i)+1)) then
          k1=amin(i)
        else
          k1=j1
        endif
        igrid=k1+na(i)*k2+na(i)*nb(i)*k3+1
        n=n+1
        d(n)=getdist(x(j,ii),y(j,ii),z(j,ii),j1*aunit,j2*bunit,j3*cunit)
        if(d(n).le.0.001) then
          dens(j,i,ii)=dens0(igrid,i)
          cycle cyclemap
        endif
        den(n)=dens0(igrid,i)
      enddo
    enddo
  enddo
  sum1= 0
  sum2= 0
  do k= 1, 8
    sum1=sum1+1/d(k)
    sum2=sum2+den(k)/d(k)
  enddo
  dens(j,i,ii)=sum2/sum1
enddo cyclemap
end subroutine getdens


subroutine cost1(i,ip,nmap,dens,edens,ii)
use parameters
use atomtype
use fcd
real, dimension(ntallmax,nmapmax,0:ntrymax) :: dens
integer, dimension(2,ntmax) :: ip

edens= 0
do j= 1, nmap
  k=ip(1,i)
  call getcost(fd1(iatom(i),j),fd2(iatom(i),j),fd3(iatom(i),j),fd4(iatom(i),j),dens(k,j,ii),tmp)
  edens=edens+fd5(iatom(i),j)*tmp*(ip(2,i)-ip(1,i)+1)
enddo
end subroutine cost1


subroutine cost2(i,ip,ipp,ncon,dist,bond,ebond,ii)
use parameters
use atomtype
use fcb
integer, dimension(ntallmax) :: ipp,ncon(ntmax,0:ntrymax),bond(4,nconmax,ntmax,0:ntrymax)
real, dimension(nconmax,ntmax,0:ntrymax) :: dist
integer, dimension(2,ntmax) :: ip
ebond=0
if (ncon(i,ii).ge.1) then
  do j= 1,ncon(i,ii)
    if (fb5(iatom(i),iatom(ipp(bond(4,j,i,ii)))).gt.0) then
      call getcost(fb1(iatom(i),iatom(ipp(bond(4,j,i,ii)))),fb2(iatom(i),iatom(ipp(bond(4,j,i,ii)))), &
      fb3(iatom(i),iatom(ipp(bond(4,j,i,ii)))),fb4(iatom(i),iatom(ipp(bond(4,j,i,ii)))),dist(j,i,ii),tmp)
      ebond=ebond+fb5(iatom(i),iatom(ipp(bond(4,j,i,ii))))*tmp
    endif
  enddo
  ebond=ebond*(ip(2,i)-ip(1,i)+1)/ncon(i,ii)
endif
end subroutine cost2


subroutine cost3(i,ip,ncon,econ,ii)
use parameters
use atomtype
use fcc
integer, dimension(ntmax,0:ntrymax) :: ncon
integer, dimension(2,ntmax) :: ip
econ= 0
if (fc5(iatom(i)).gt.0) then
  call getcost(fc1(iatom(i)),fc2(iatom(i)),fc3(iatom(i)),fc4(iatom(i)),1.0*ncon(i,ii),tmp)
  econ=econ+fc5(iatom(i))*tmp*(ip(2,i)-ip(1,i)+1)
endif
end subroutine cost3


subroutine cost4(i,ip,x,y,z,ipp,ncon,dist,bond,eub,eang,w3mr,e3mr,ii)
use parameters
use atomtype
use fcb
use fcu
use fca
real, dimension(ntallmax,0:ntrymax) :: x,y,z
real, dimension(nconmax,ntmax,0:ntrymax) :: dist
integer, dimension(ntmax,0:ntrymax) :: ncon,bond(4,nconmax,ntmax,0:ntrymax),ipp(ntallmax)
integer, dimension(2,ntmax) :: ip
eub= 0
eang= 0
nang= 0
nub= 0
e3mr= 0
if (ncon(i,ii).ge.2) then
  do j= 1,ncon(i,ii)-1
    do k=j+1,ncon(i,ii)
      j1=bond(1,j,i,ii)
      j2=bond(2,j,i,ii)
      j3=bond(3,j,i,ii)
      j4=bond(4,j,i,ii)
      j5=ipp(bond(4,j,i,ii))
      k1=bond(1,k,i,ii)
      k2=bond(2,k,i,ii)
      k3=bond(3,k,i,ii)
      k4=bond(4,k,i,ii)
      k5=ipp(bond(4,k,i,ii))
      d=getdist(x(j4,ii)+j1,y(j4,ii)+j2,z(j4,ii)+j3,x(k4,ii)+k1,y(k4,ii)+k2,z(k4,ii)+k3)
      if (w3mr.gt.0) then
        if (d.le.dtmax(iatom(j5),iatom(k5))) e3mr=e3mr+w3mr
      endif
      if (fu5(iatom(j5),iatom(i),iatom(k5)).gt.0) then
        call getcost(fu1(iatom(j5),iatom(i),iatom(k5)),fu2(iatom(j5),iatom(i),iatom(k5)), &
        fu3(iatom(j5),iatom(i),iatom(k5)),fu4(iatom(j5),iatom(i),iatom(k5)),d,tmp)
        eub=eub+fu5(iatom(j5),iatom(i),iatom(k5))*tmp
        nub=nub+1
      endif
      if (fa5(iatom(j5),iatom(i),iatom(k5)).gt.0) then
        call angle(dist(j,i,ii),dist(k,i,ii),d,angtmp)
        call getcost(fa1(iatom(j5),iatom(i),iatom(k5)),fa2(iatom(j5),iatom(i),iatom(k5)), &
        fa3(iatom(j5),iatom(i),iatom(k5)),fa4(iatom(j5),iatom(i),iatom(k5)),angtmp,tmp)
        eang=eang+fa5(iatom(j5),iatom(i),iatom(k5))*tmp
        nang=nang+1
      endif
    enddo
  enddo
endif

if (nang.gt.0) eang=eang*(ip(2,i)-ip(1,i)+1)/nang
if (nub.gt.0) eub=eub*(ip(2,i)-ip(1,i)+1)/nub
end subroutine cost4


FUNCTION GETDIST(XM,YM,ZM,XN,YN,ZN)
use cell2
DX=XM-XN
DY=YM-YN
DZ=ZM-ZN
GETDIST2=A2*(DX*DX)+B2*(DY*DY)+C2*(DZ*DZ)+abcoga2*DX*DY+accobe2*DX*DZ+bccoal2*DY*DZ
getdist=sqrt(abs(getdist2))
END function GETDIST


subroutine envi(i,x,y,z,ip,ipp,ntall,ncon,bond,dist,ii)
use parameters
use atomtype
use fcb
real, dimension(ntallmax,0:ntrymax) :: x,y,z
real, dimension(3) :: dist(nconmax,ntmax,0:ntrymax)
integer, dimension(6) :: loop,ip(2,ntmax),ipp(ntallmax),ncon(ntmax,0:ntrymax),bond(4,nconmax,ntmax,0:ntrymax)

ncon(i,ii)= 0
call  box(x(ip(1,i),ii),y(ip(1,i),ii),z(ip(1,i),ii),loop)
do k1=loop(1),loop(2)
  do k2=loop(3),loop(4)
    do k3=loop(5),loop(6)
      do j= 1,ntall
        if (ip(1,i).eq.j .and. k1.eq.0 .and. k2.eq.0 .and. k3.eq.0) cycle
        if (abs(X(ip(1,i),ii)-(X(j,ii)+k1)).gt.enva) cycle
        if (abs(y(ip(1,i),ii)-(y(j,ii)+k2)).gt.envb) cycle
        if (abs(z(ip(1,i),ii)-(z(j,ii)+k3)).gt.envc) cycle
        d=getdist(X(ip(1,i),ii),Y(ip(1,i),ii),Z(ip(1,i),ii),X(j,ii)+k1,Y(j,ii)+k2,Z(j,ii)+k3)
        if (d.le.dtmax(iatom(i),iatom(ipp(j)))) then
          ncon(i,ii)=ncon(i,ii)+1
          if (ncon(i,ii).gt.nconmax) then
            write(0,*)'Error on calcuating bond environment: Too many bonds!'
            stop
          endif
          dist(ncon(i,ii),i,ii)=d
          bond(1,ncon(i,ii),i,ii)=k1
          bond(2,ncon(i,ii),i,ii)=k2
          bond(3,ncon(i,ii),i,ii)=k3
          bond(4,ncon(i,ii),i,ii)=j
        endif
      enddo
    enddo
  enddo
enddo
end subroutine envi


subroutine envi2(i,j,x,y,z,ip,ncon,bond,dist,ii)
use parameters
use atomtype
use fcb
real, dimension(ntallmax,0:ntrymax) :: x,y,z
real, dimension(3) :: dist(nconmax,ntmax,0:ntrymax)
integer, dimension(4,nconmax,ntmax,0:ntrymax) :: bond,ncon(ntmax,0:ntrymax),ip(2,ntmax),loop(6)

nncon= 0
do k= 1,ncon(i,ii)
  if (bond(4,k,i,ii).lt.ip(1,j).or.bond(4,k,i,ii).gt.ip(2,j)) then
    nncon=nncon+1
    bond(4,nncon,i,ii)=bond(4,k,i,ii)
    bond(3,nncon,i,ii)=bond(3,k,i,ii)
    bond(2,nncon,i,ii)=bond(2,k,i,ii)
    bond(1,nncon,i,ii)=bond(1,k,i,ii)
    dist(nncon,i,ii)=dist(k,i,ii)
  endif
enddo
ncon(i,ii)=nncon
call  box(x(ip(1,i),ii),y(ip(1,i),ii),z(ip(1,i),ii),loop)
do k1=loop(1),loop(2)
  do k2=loop(3),loop(4)
    do k3=loop(5),loop(6)
      do l=ip(1,j),ip(2,j)
        if (abs(X(ip(1,i),ii)-(X(l,ii)+k1)).gt.enva) cycle
        if (abs(y(ip(1,i),ii)-(y(l,ii)+k2)).gt.envb) cycle
        if (abs(z(ip(1,i),ii)-(z(l,ii)+k3)).gt.envc) cycle
        d=getdist(X(ip(1,i),ii),Y(ip(1,i),ii),Z(ip(1,i),ii),X(l,ii)+k1,Y(l,ii)+k2,Z(l,ii)+k3)
        if (d.le.dtmax(iatom(i),iatom(j))) then
          ncon(i,ii)=ncon(i,ii)+1
          if (ncon(i,ii).gt.nconmax) then
            write(0,*)'Error on calcuating bond environment: Too many bonds!'
            stop
          endif
          dist(ncon(i,ii),i,ii)=d
          bond(1,ncon(i,ii),i,ii)=k1
          bond(2,ncon(i,ii),i,ii)=k2
          bond(3,ncon(i,ii),i,ii)=k3
          bond(4,ncon(i,ii),i,ii)=l
        endif
      enddo
    enddo
  enddo
enddo
end subroutine envi2


subroutine getcsq(x,y,z,nuniq,ntall,iwyck1,ip,ipp,ncon,bond,ncs,ii)
use parameters
use atomtype
use fcb
real, dimension(ntallmax,0:ntrymax) :: x, y, z
integer, dimension(6) :: loop,ip(2,ntmax),ipp(ntallmax),iwyck1(ntmax)
integer, dimension(ntmax,0:ntrymax) :: ncon
integer, dimension(5,nbmax) :: bond(4,nconmax,ntmax,0:ntrymax),nbr0,nbr1
integer, dimension(nshellmax,ntmax) :: ncs
integer, dimension(-nbox:nbox,-nbox:nbox,-nbox:nbox,ntall) :: ics

ncs= 0
do i= 1,nuniq
  if (iwyck1(i).eq.0) cycle
  if (ncon(i,ii).ge.1) then
    ics= -1
    ncs(1,i)=ncon(i,ii)
    ics(0,0,0,ip(1,i))= 1
    do k= 1,ncon(i,ii)
      ics(bond(1,k,i,ii),bond(2,k,i,ii),bond(3,k,i,ii),bond(4,k,i,ii))= 1
      nbr1(1,k)=bond(1,k,i,ii)
      nbr1(2,k)=bond(2,k,i,ii)
      nbr1(3,k)=bond(3,k,i,ii)
      nbr1(4,k)=bond(4,k,i,ii)
      nbr1(5,k)=ipp(bond(4,k,i,ii))
    enddo
    nshell= 1
    cycleshell: do
      nbr0=nbr1
      do j= 1, ncs(nshell,i)
        j1=nbr0(1,j)
        j2=nbr0(2,j)
        j3=nbr0(3,j)
        j4=nbr0(4,j)
        j5=nbr0(5,j)
        call  box(x(j4,ii),y(j4,ii),z(j4,ii),loop)
        do k= 1, ncon(j5,ii)
          k5=ipp(bond(4,k,j5,ii))
          do k4=ip(1,k5),ip(2,k5)
            do k1=j1+loop(1),j1+loop(2)
              do k2=j2+loop(3),j2+loop(4)
                do k3=j3+loop(5),j3+loop(6)
                  if (k1.eq.j1.and.k2.eq.j2.and.k3.eq.j3.and.k4.eq.j4) cycle
                  if (ics(k1,k2,k3,k4).gt.0) cycle
                  d=getdist(X(j4,ii)+j1,Y(j4,ii)+j2,Z(j4,ii)+j3,X(k4,ii)+k1,Y(k4,ii)+k2,Z(k4,ii)+k3)
                  if (d.le.dtmax(iatom(k5),iatom(j5))) then
                    ncs(nshell+1,i)=ncs(nshell+1,i)+1
                    if (ncs(nshell+1,i).gt.nbmax) then
                      write(0,*)'Error on calculating CSQs: Too many bonds!'
                      return
                    endif
                    nbr1(1,ncs(nshell+1,i))=k1
                    nbr1(2,ncs(nshell+1,i))=k2
                    nbr1(3,ncs(nshell+1,i))=k3
                    nbr1(4,ncs(nshell+1,i))=k4
                    nbr1(5,ncs(nshell+1,i))=k5
                    if (abs(k1).gt.nbox.or.abs(k2).gt.nbox.or.abs(k3).gt.nbox) then
                      write(0,*)'Error on calculating CSQs: Atoms out of range!'
                      return
                    endif
                    ics(k1,k2,k3,k4)= 1
                  endif
                enddo
              enddo
            enddo
          enddo
        enddo
      enddo
      nshell=nshell+ 1
      if (nshell.eq.nshellmax) exit cycleshell
    enddo cycleshell
  endif
enddo
end subroutine getcsq


subroutine box(x,y,z,loop)
use fcb
use atomtype
integer, dimension(6) :: loop

loop = 0
if ((x-enva).le.0) loop(1)= -1
if ((x+enva).ge.1) loop(2)= 1
if ((y-envb).le.0) loop(3)= -1
if ((y+envb).ge.1) loop(4)= 1
if ((z-envc).le.0) loop(5)= -1
if ((z+envc).ge.1) loop(6)= 1

end subroutine box


SUBROUTINE symm1(filesymm,spg)
use symmetry
CHARACTER :: spg*8,TEM*8,filesymm*32

ispecial= -1
OPEN(9,FILE=trim(filesymm),STATUS= 'old')
readspg: do
  READ(9,'(a)', iostat = iostatus)TEM
  if (iostatus.lt.0) then
    close(9)
    write(0,*)'Cannot find space group ',spg
    stop
  endif
  IF(TEM.EQ.spg)THEN
    READ(9,*)family
    read(9,*)nsym
    do i= 1, nsym
      read(9,'(i3,x,a,x,a)')np(i),wyck(i),site(i)
      do j= 1, np(i)
        READ(9,*)(matrix(k,j,i), k= 1, 12)
      enddo
    enddo

    checkspecial: do i= 1,nsym
      innercheck: do k= 1, 11
        if (k.eq.4.or.k.eq.8) cycle innercheck
        if (abs(matrix(k,1,i)-0).gt.0.001) cycle checkspecial
      enddo innercheck
      ispecial(i)= 1
    enddo checkspecial
    exit readspg
  endif
enddo readspg
CLOSE(9)
END subroutine symm1


subroutine symm2(x0,y0,z0,iwyck,wyck1)
use symmetry
parameter (tinynumber= 0.001)
character(len=1) :: wyck1
real, dimension(192) :: x1,y1,z1,x2,y2,z2
integer, dimension(192) :: ie1,ie2

iwyck= -1
if (nsym.eq.1) then
  iwyck=1
  return
endif

do i= 1, nsym
  if (wyck(i).eq.wyck1) iwyck=i
enddo

do i= 1, np(1)
  x1(i)=matrix(1,i,1)*x0+matrix(2,i,1)*y0+matrix(3,i,1)*z0+matrix(4,i,1)
  x1(i)=translate(x1(i))
  y1(i)=matrix(5,i,1)*x0+matrix(6,i,1)*y0+matrix(7,i,1)*z0+matrix(8,i,1)
  y1(i)=translate(y1(i))
  z1(i)=matrix(9,i,1)*x0+matrix(10,i,1)*y0+matrix(11,i,1)*z0+matrix(12,i,1)
  z1(i)=translate(z1(i))
enddo

if (iwyck.gt.1) then
  checkposition: do i= 1, np(1)
    ie1= -1
    ie2= -1
    do j=1,np(iwyck)
      x2(j)=matrix(1,j,iwyck)*x1(i)+matrix(2,j,iwyck)*y1(i)+matrix(3,j,iwyck)*z1(i)+matrix(4,j,iwyck)
      x2(j)=translate(x2(j))
      y2(j)=matrix(5,j,iwyck)*x1(i)+matrix(6,j,iwyck)*y1(i)+matrix(7,j,iwyck)*z1(i)+matrix(8,j,iwyck)
      y2(j)=translate(y2(j))
      z2(j)=matrix(9,j,iwyck)*x1(i)+matrix(10,j,iwyck)*y1(i)+matrix(11,j,iwyck)*z1(i)+matrix(12,j,iwyck)
      z2(j)=translate(z2(j))
    enddo
    do j2=1,np(iwyck)
      do j1=1,np(1)
        if (ie1(j1).lt.0) then
          if (abs(x2(j2)-x1(j1)).le.tinynumber.and.abs(y2(j2)-y1(j1)).le.tinynumber.and. &
            abs(z2(j2)-z1(j1)).le.tinynumber) then
            ie1(j1)=1
            ie2(j2)=1
          endif
        endif
      enddo
      if (ie2(j2).lt.0) cycle checkposition
    enddo
    x0=x2(1)
    y0=y2(1)
    z0=z2(1)
    return
  enddo checkposition
endif

if (wyck1.eq.'@') then
  do k=nsym,2,-1
    checkposition2: do i= 1, np(1)
      ie1= -1
      ie2= -1
      do j= 1, np(k)
        x2(j)=matrix(1,j,k)*x1(i)+matrix(2,j,k)*y1(i)+matrix(3,j,k)*z1(i)+matrix(4,j,k)
        x2(j)=translate(x2(j))
        y2(j)=matrix(5,j,k)*x1(i)+matrix(6,j,k)*y1(i)+matrix(7,j,k)*z1(i)+matrix(8,j,k)
        y2(j)=translate(y2(j))
        z2(j)=matrix(9,j,k)*x1(i)+matrix(10,j,k)*y1(i)+matrix(11,j,k)*z1(i)+matrix(12,j,k)
        z2(j)=translate(z2(j))
      enddo
      do j2= 1,np(k)
        do j1= 1,np(1)
          if (ie1(j1).lt.0) then
            if ((abs(x2(j2)-x1(j1)).le.tinynumber.or.abs(abs(x2(j2)-x1(j1))-1).le.tinynumber).and. &
              (abs(y2(j2)-y1(j1)).le.tinynumber.or.abs(abs(y2(j2)-y1(j1))-1).le.tinynumber).and. &
              (abs(z2(j2)-z1(j1)).le.tinynumber.or.abs(abs(z2(j2)-z1(j1))-1).le.tinynumber)) then
              ie1(j1)= 1
              ie2(j2)= 1
            endif
          endif
        enddo
        if (ie2(j2).lt.0) cycle checkposition2
      enddo
      iwyck=k
      x0=x2(1)
      y0=y2(1)
      z0=z2(1)
      return
    enddo checkposition2
  enddo
  iwyck= 1
endif

if (iwyck.lt.0 .and. wyck1.ne.'?') then
  write(0,*)'unknown wyckoff position',wyck1
  stop
endif

end subroutine symm2


SUBROUTINE symm3(i,x0,y0,z0,ip,x,y,z,iwyck,ii)
use parameters
use symmetry
integer, dimension(ntmax) :: iwyck,ip(2,ntmax)
real, dimension(ntallmax,0:ntrymax) :: x,y,z

j1=ip(1,i)
j2=ip(2,i)
do j=j1,j2
  x(j,ii)=matrix(1,j+1-j1,iwyck(i))*x0+matrix(2,j+1-j1,iwyck(i))*y0+matrix(3,j+1-j1,iwyck(i))*z0+matrix(4,j+1-j1,iwyck(i))
  x(j,ii)=translate(x(j,ii))
  y(j,ii)=matrix(5,j+1-j1,iwyck(i))*x0+matrix(6,j+1-j1,iwyck(i))*y0+matrix(7,j+1-j1,iwyck(i))*z0+matrix(8,j+1-j1,iwyck(i))
  y(j,ii)=translate(y(j,ii))
  z(j,ii)=matrix(9,j+1-j1,iwyck(i))*x0+matrix(10,j+1-j1,iwyck(i))*y0+matrix(11,j+1-j1,iwyck(i))*z0+matrix(12,j+1-j1,iwyck(i))
  z(j,ii)=translate(z(j,ii))
enddo
x0=x(ip(1,i),ii)
y0=y(ip(1,i),ii)
z0=z(ip(1,i),ii)
END subroutine symm3


function translate(a)
checknegative: do
  if (a.lt.0.0) then
    a = a + 1
  else
    exit checknegative
  endif
enddo checknegative
translate=amod(a, 1.0)
end function translate


subroutine swapi(i,j)
k=j
j=i
i=k
end subroutine swapi

subroutine swap4(a,b)
t=a
a=b
b=t
end subroutine swap4

subroutine swap8(a,b)
real(8) a,b,t
t=a
a=b
b=t
end subroutine swap8


subroutine checkcost(i)
if (i.lt.1 .or. i.gt.9) then
i= -1
endif
end subroutine checkcost


subroutine getcost(i,a,b,c,x,e)
e=0
select case (i)
  case (1)
    e=(x-a)*(x-a)
  case (2)
    if (x.gt.b) then
      e=(x-a)*(x-a)
    else
      e= 0
    endif
  case (3)
    if (x.lt.b) then
      e=(x-a)*(x-a)
    else
      e= 0
    endif
  case (4)
    if (x.lt.a) then
      e=(x-a)*(x-a)
    else
      if (x.gt.b) then
        e=(x-b)*(x-b)
      else
        e=0
      endif
    endif
  case (5)
    if (x.gt.b) then
      e=(x-a)*(x-a)
    else
      e=c*(x-a)*(x-a)
    endif
  case (6)
    e=exp(b*(1.0-x/a))
  case (7)
    e = (1-exp(-b*(x-a)))**2
  case (8)
    e = b*exp(-x/a)-c/x**6
  case (9)
    e = (a/x)**12-(a/x)**6
  case (10)
    e = (a/x)**b-(a/x)**c
  case (11)
    e=(x-a)**b
  case (12)
    if (x.gt.b) then
      e=(x-a)**c
    else
      e= 0
    endif
  case (13)
    if (x.lt.b) then
      e=(x-a)**c
    else
      e= 0
    endif
  case (14)
    if (x.lt.a) then
      e=(x-a)**c
    else
      if (x.gt.b) then
        e=(x-b)**c
      else
        e=0
      endif
    endif
  case default
    write(0,*)'unknown function code: ', i
    stop
end select
end subroutine getcost


subroutine angle(a,b,c,ang)
use parameters

if (a.lt.0.00001) a= 0.00001
if (b.lt.0.00001) b= 0.00001
x=(a*a+b*b-c*c)/(2.0*a*b)
if (x.ge.1.0) x= 1.0
if (x.le.-1.0) x= -1.0
ang=(acos(x))*180.0/pi
end subroutine angle


subroutine getsfac(ntype,element,nhkl,h0,k0,l0,d,filesfac,f)
use parameters
real, dimension(5,ntmax) :: a0,b0,c0(ntmax),f(ntmax,nhklmax),d(nhklmax)
integer, dimension(nhklmax) :: h0,k0,l0
character, dimension(ntypemax) :: element*4
character :: eletemp*4,filesfac*32

do i= 1, ntype
  
  open(unit= 18, file=trim(filesfac), status= 'unknown')
  findelement: do
    read(18, *, iostat = iostatus)eletemp
    if (iostatus.lt.0) then
      write(0,*)' cannot get scattering factor for ',element(i)
      close(18)
      stop
    endif
    IF(eletemp.EQ.element(i))THEN
      read(18,*,iostat = iostatus)(a0(j,i),b0(j,i),j= 1, 5),c0(i)
      close(18)
      exit findelement
      if (iostatus.lt.0) then
        write(0,*)' Error on reading scattering factor for ', element(i)
        close(18)
        stop
      endif
    endif
    cycle findelement
  enddo findelement
enddo
do i= 1, nhkl
  d(i)=sqrt(dsq(h0(i),k0(i),l0(i)))
  s= 0.5/d(i)
  do j= 1, ntype
    f(j,i)= 0
    do k= 1, 5
      f(j,i)=f(j,i)+a0(k,j)*exp(-b0(k,j)*s**2)
    enddo
    f(j,i)=f(j,i)+c0(j)
  enddo
enddo

end subroutine getsfac



function dsq(h,k,l)
use cell
integer :: h,k,l

sial=sqrt(1-coal*coal)
sibe=sqrt(1-cobe*coal)
siga=sqrt(1-coga*coal)
d21=(h*blength*clength*sial)**2
d22=(k*alength*clength*sibe)**2
d23=(l*blength*alength*siga)**2
d24=2*h*k*alength*blength*(clength*clength)*(coal*cobe-coga)
d25=2*l*k*clength*blength*(alength*alength)*(coga*cobe-coal)
d26=2*h*l*alength*clength*(blength*blength)*(coal*coga-cobe)
d27=(alength*alength)*(blength*blength)*(clength*clength)*(1-coal*coal-cobe*cobe-coga*coga+2*coal*cobe*coga)
dsq=d27/(d21+d22+d23+d24+d25+d26)
end function dsq


subroutine getf0(i,x,y,z,ip,nhkl,h0,k0,l0,f,f02,ii)
use parameters
use atomtype
integer,dimension(nhklmax) :: h0,k0,l0,ip(2,ntmax)
real, dimension(ntallmax,0:ntrymax) :: x,y,z
real, dimension(ntmax,nhklmax) :: f,f02(2,nhklmax,ntmax,0:ntrymax)
real :: re,im

do j= 1,nhkl
  re= 0
  im= 0
  do k=ip(1,i),ip(2,i)
    dotproduct=2*pi*(h0(j)*x(k,ii)+k0(j)*y(k,ii)+l0(j)*z(k,ii))
    re=re+f(iatom(i),j)*cos(dotproduct)
    im=im+f(iatom(i),j)*sin(dotproduct)
  enddo
  f02(1,j,i,ii)=re
  f02(2,j,i,ii)=im
enddo
end subroutine getf0


subroutine getf(nuniq,iwyck,nhkl,f02,f2,ii)
use parameters
use rfactor
real, dimension(2,nhklmax,ntmax,0:ntrymax) :: f02,f2(3,nhklmax,0:ntrymax)
integer, dimension(ntmax) :: iwyck
real :: re,im
f2max=0
do i= 1,nhkl
  re= 0
  im= 0
  do j= 1,nuniq
    if (iwyck(j).eq.0) cycle
    re=re+f02(1,i,j,ii)
    im=im+f02(2,i,j,ii)
  enddo
  f2(1,i,ii)=re
  f2(2,i,ii)=im
  f2(3,i,ii)=re*re+im*im
  if (f2(3,i,ii).gt.f2max) f2max=f2(3,i,ii)
enddo
end subroutine getf


subroutine cost5(nhkl,f2,ehkl,ii)
use parameters
use rfactor
real, dimension(3,nhklmax,0:ntrymax) :: f2
ehkl= 0
r1= 0
do i= 1,nhkl
  r1=r1+weight(i)*(fo(i)/fomax-f2(3,i,ii)/f2max)**2
enddo
ehkl=wcost5*r1/weightsum
end subroutine cost5


subroutine hklweight(h0,k0,l0,i)
use parameters
use rfactor
use symmetry
integer,dimension(192) :: h,k,l
integer :: h0,k0,l0,m

m=np(1)
do j=1,np(1)
  h(j)=nint(h0*matrix(1,j,1))+nint(k0*matrix(5,j,1))+nint(l0*matrix(9,j,1))
  k(j)=nint(h0*matrix(2,j,1))+nint(k0*matrix(6,j,1))+nint(l0*matrix(10,j,1))
  l(j)=nint(h0*matrix(3,j,1))+nint(k0*matrix(7,j,1))+nint(l0*matrix(11,j,1))
enddo
getm1: do j1=1,np(1)-1
  if (h(j1).eq.99999) cycle getm1
  getm2: do j2=j1+1,np(1)
    if (h(j2).eq.99999) cycle getm2
    if (h(j1).eq.h(j2).and.k(j1).eq.k(j2).and.l(j1).eq.l(j2)) then
      h(j2)=99999
      m=m-1
    endif
  enddo getm2
enddo getm1
weight(i)=m
end subroutine hklweight

subroutine geti(nuniq,ntall,np,iwyck1,ip,ipp)
use parameters
integer, dimension(2,ntmax) :: ip,ipp(ntallmax),np(27),iwyck1(ntmax)
ntall= 0
do j= 1,nuniq
  if (iwyck1(j).eq.0) cycle
  ip(1,j)=ntall+1
  ip(2,j)=ntall+np(iwyck1(j))
  ntall=ip(2,j)
  do k=ip(1,j),ip(2,j)
    ipp(k)=j
  enddo
enddo
end subroutine geti

subroutine mytrim(a,b,lena,lenb,lenbfinal)
character(len=lena) :: a
character(len=lenb) :: b
b=''
j=0
getcharacter: do i=1,lena
  if (a(i:i).eq.'!' .or. a(i:i).eq.'#') exit getcharacter
  if (a(i:i).ne.' '.and.a(i:i).ne.'"'.and.a(i:i).ne."'") then
    j=j+1
    b(j:j)=a(i:i)
    if (j.eq.lenb) exit getcharacter
  endif
enddo getcharacter
lenbfinal=j
end subroutine mytrim

subroutine nocomment(line)
use parameters
character(len=linemax) :: line
findcomment: do i=1,linemax
  if (line(i:i).eq.'!'.or.line(i:i).eq.'#') then
    do j=i,linemax
      line(j:j)=' '
    enddo
    exit findcomment
  endif
enddo findcomment
end subroutine nocomment

subroutine oneblank(line)
character(len=512) :: line
do i=len_trim(line),2,-1
  if (line(i-1:i).eq.'  ') then
    line(i-1:len_trim(line)-1)=line(i:len_trim(line))
    line(len_trim(line):len_trim(line))=' '
  endif
enddo
end subroutine oneblank
