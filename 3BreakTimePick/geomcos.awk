# awk script to do cosine correction

function applyscalel(var,scal)
{
    out=var/(scal*-1*10)
	return out
}

function applyscalco(var,scal)
{
    out=var/(scal*-1)
	return out
}

function dist(x1,y1,x2,y2)
{
    out=sqrt((x2-x1)^2+(y2-y1)^2)
	return out
}

function getangle(sroffset,rz,sz)
{
	#angle in radian
    angle=atan2(sroffset,(rz-sz))
	return angle
}

#fix getazi, not correct
function getazi(x1,y1,x2,y2)
{
	#angle in radian
    angle=(180/3.1415)*atan2((y2-y1),(x2-x1))
	return angle
}

function getstat(z1,z2,v)
{
	shiftstat=sqrt((z2-z1)^2)/v
	return shiftstat
}

function tosrd(var,log_zero)
{
	srd=var-log_zero
	return srd
}

BEGIN { 
#this formatting is stupid, need to make better formating :)
#printf "NO \t\t SX \t\t SY \t\t SZ \t\t RX \t\t RY \t RZ_MD \t\t RZ_TVDSS \t ROFF \t SROFF \t TT_OBS \t TT_VERT \t TT_SRD  \t DZ \t\t DT  \t\t VINT  \n"
	}

	{
	sx=applyscalco($4,$2)
	sy=applyscalco($5,$2)
	sz=tosrd(src_z_log_zero,log_zero)
	rx=applyscalco($7,$2)
	ry=applyscalco($8,$2)
	cl=applyscalel($9,$3)
	rz=tosrd(cl,log_zero)
	roffset=dist(rx,ry,wellx,welly)
	sroffset=dist(sx,sy,rx,ry)
#	srazi=getazi(sx,sy,wellx,welly)
	angle=getangle(sroffset,rz,sz)
	stat_hyd_src=getstat(src_z_log_zero,sensor_z_log_zero,vhyd)
	stat_src_srd=getstat(src_z_log_zero,log_zero,vmedium)
	tt_obs=$10/1000
	tt_src_rec=tt_obs+stat_hyd_src
	tt_vert=tt_src_rec*cos(angle)
	tt_srd=tt_vert+stat_src_srd
	dz[NR]=rz
	dt[NR]=tt_srd
	tshift=tt_srd-tt_obs
#	printf "%3d \t %5.2f \t %5.2f \t %5.2f \t %5.2f \t %5.2f \t %6.2f \t %6.2f \t %5.2f \t %5.2f \t %5.2f  \t %3f  \t %3f \t %3.4f \t %3.4f \t %3.4f  \t %3.4f \n", \
#		    $1,sx,sy,sz,rx,ry,cl,rz,roffset,sroffset,angle,stat_hyd_src,stat_src_srd,tt_obs,tt_src_rec,tt_vert,tt_srd
#	}
	printf "%3d \t %5.2f \t %5.2f \t %5.2f \t %5.2f \t %5.2f \t %6.2f \t %6.2f \t %5.2f \t %5.2f \t %3.4f \t %3.4f \t %3.4f  \t %3.4f \t %3.4f  \t %3.2f \t %3.3f \n", \
		    $1,sx,sy,sz,rx,ry,cl,rz,roffset,sroffset,tt_obs,tt_vert,tt_srd,(dz[NR]-dz[NR-1]),(dt[NR]-dt[NR-1]),(dz[NR]-dz[NR-1])/(dt[NR]-dt[NR-1]),tshift
	}