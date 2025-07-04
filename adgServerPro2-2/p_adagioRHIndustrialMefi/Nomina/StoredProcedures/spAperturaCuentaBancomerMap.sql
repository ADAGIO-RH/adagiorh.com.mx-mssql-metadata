USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spAperturaCuentaBancomerMap](    
	@FechaInicio Date,    
	@FechaFin Date,   
	@IDLayout int,    
	@IDUsuario int    
)    
AS    
BEGIN    
	   
	declare @dtEmpleados RH.dtEmpleados    
    
	insert into @dtEmpleados    
	exec RH.spBuscarEmpleados @FechaIni= @FechaInicio, @Fechafin = @FechaFin, @IDUsuario = @IDUsuario    
 
    IF object_ID('TEMPDB..#TempRegistros') IS NOT NULL DROP TABLE #TempRegistros  
  
	DELETE @dtEmpleados  
	WHERE IDEmpleado IN (  
		SELECT IDEmpleado FROM imss.tblMovAfiliatorios MOV WITH(NOLOCK)  
			INNER JOIN imss.tblCatTipoMovimientos tm WITH(NOLOCK)  
				on tm.IDTipoMovimiento = mov.IDTipoMovimiento  
		WHERE Fecha between @FechaInicio and @FechaFin  
			and tm.Codigo = 'B'  
	)   
    
	select     
		e.ClaveEmpleado as [Clave_Colaborador],    
		COALESCE(E.Nombre,'')+' '+COALESCE(E.SegundoNombre,'') as Nombres,    
		isnull(e.Paterno,'')          as Paterno,    
		isnull(e.Materno,'')          as Materno,    
		format(e.FechaNacimiento,'yyyy-MM-dd')     as [Fecha_Nacimiento],    
		case when e.EstadoCivil = 'CASADO' THEN 'C'    
			when e.EstadoCivil = 'SOLTERO' THEN 'S'    
			when e.EstadoCivil = 'VIUDO' THEN 'V'    
			when e.EstadoCivil = 'DIVORCIADO' THEN 'D'    
			when e.EstadoCivil = 'UNION LIBRE' THEN 'U'    
		ELSE 'S' END            as [Estado_Civil],    
		isnull(e.CURP,'')       as CURP,    
		CASE WHEN e.Sexo = 'MASCULINO' THEN 'M'    
		else 'F' END           as Sexo,    
		case when ISNULL(e.PaisNacimiento,'MEXICO') = 'MEXICO' THEN 'M'    
		ELSE 'E' END            as Nacionalidad ,    
		isnull(p.Codigo,'')     as [Codigo_Pais],    
		format(e.FechaAntiguedad,'yyyy-MM-dd')					as [Fecha_Antiguedad],    
		isnull(replace(replace(de.Calle,'''',''),'"',''),'')	as Calle , 
		isnull(replace(replace(de.Exterior,'''',''),'"',''),'SN')	as Exterior ,     
		isnull(replace(replace(de.Colonia,'''',''),'"',''),'')		as Colonia ,  
		isnull(de.CodigoPostal,'77710')			as [Codigo_Postal],    
		isnull(de.Municipio,'')					as Municipio,    
		isnull(de.Estado,'')					as Estado,    
		isnull(ce.Value,'9848773500')			as [Telefono_Trabajador],    
		'9848773500'            as [Otro_Telefono],    
		replace(isnull(pe.Tarjeta,''),' ','')      as Tarjeta,    
		'5133'             as [Sucursal_Gestora],  
		ROW_NUMBER()OVER(Partition by e.ClaveEmpleado order by e.ClaveEmpleado asc) as RN  
	into #TempRegistros    
	from @dtEmpleados e    
		left join rh.tblPagoEmpleado pe with (nolock) on e.IDEmpleado = pe.IDEmpleado  
			and pe.IDLayoutPago = @IDLayout 
		left join Nomina.tblLayoutPago lp with (nolock) on lp.IDLayoutPago = pe.IDLayoutPago   
		left join Nomina.tblCatTiposLayout tl with (nolock) on lp.IDTipoLayout = tl.IDTipoLayout    
		left join rh.tblDireccionEmpleado de with (nolock) on e.IDEmpleado = de.IDEmpleado    
			and de.FechaIni<= @Fechafin and de.FechaFin >= @Fechafin    
		left join RH.tblContactoEmpleado ce with (nolock) on e.IDEmpleado = ce.IDEmpleado    
		left join rh.tblCatTipoContactoEmpleado tce with (nolock) on ce.IDTipoContactoEmpleado = tce.IDTipoContacto    
			and tce.IDMedioNotificacion in ('Celular', 'TelefonoFijo')
		left join sat.tblCatPaises p with (nolock)  on e.IDPaisNacimiento  = p.IDPais    
	 where (pe.IDLayoutPago is null or (pe.IDLayoutPago = @IDLayout and pe.cuenta is null and pe.tarjeta is null)) 
  
	select    
		[Clave_Colaborador],    
		Nombres,    
		Paterno,    
		Materno,    
		[Fecha_Nacimiento],    
		[Estado_Civil],    
		CURP,    
		Sexo,    
		Nacionalidad ,    
		[Codigo_Pais],    
		[Fecha_Antiguedad],    
		Calle ,    
		Exterior,    
		Colonia,    
		[Codigo_Postal],    
		Municipio,    
		Estado,    
		[Telefono_Trabajador],    
		[Otro_Telefono],    
		Tarjeta,    
		[Sucursal_Gestora]  
	from #TempRegistros  
	where RN = 1  
	ORDER BY Clave_Colaborador ASC  
    
END
GO
