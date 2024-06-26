USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Nomina].[spAperturaCuentaBancomer]--'2019-12-05','2019-12-05',1       
(    
	@FechaInicio Date,    
	@FechaFin Date,   
	@IDLayout int, 
	@IDUsuario int    
)    
AS    
BEGIN    
    
	declare @dtEmpleados RH.dtEmpleados    
     
    if object_id('tempdb..#tempResp') is not null drop table #tempResp;    
	if object_id('tempdb..#tempRegistros') is not null drop table #tempRegistros;    
    
    create table #tempResp(Respuesta nvarchar(max));    
    
	insert into @dtEmpleados    
	exec RH.spBuscarEmpleados @FechaIni= @FechaInicio, @Fechafin = @FechaFin, @IDUsuario = @IDUsuario    
 
	Select     
		e.ClaveEmpleado as [Clave_Colaborador],    
		CASE WHEN COALESCE(LTRIM(RTRIM(isnull(E.SegundoNombre,''))), '') = '' THEN COALESCE(LTRIM(RTRIM(isnull(E.Nombre,''))), '') ELSE COALESCE(LTRIM(RTRIM(isnull(E.Nombre,''))), '')+' ' END+RTRIM(LTRIM(isnull(E.SegundoNombre,''))) as Nombres,    
		RTRIM(LTRIM(isnull(e.Paterno,''))) as Paterno,    
		RTRIM(LTRIM(isnull(e.Materno,''))) as Materno,    
		format(e.FechaNacimiento,'yyyy-MM-dd') as [Fecha_Nacimiento],    
		case when e.EstadoCivil = 'CASADO' THEN 'C'    
			when e.EstadoCivil = 'SOLTERO' THEN 'S'    
			when e.EstadoCivil = 'VIUDO' THEN 'V'    
			when e.EstadoCivil = 'DIVORCIADO' THEN 'D'    
			when e.EstadoCivil = 'UNION LIBRE' THEN 'U'    
		ELSE 'S' END as [Estado_Civil],    
		RTRIM(LTRIM(isnull(e.CURP,''))) as CURP,    
		CASE WHEN e.Sexo = 'MASCULINO' THEN 'M'    
			else 'F' END as Sexo,    
		case when ISNULL(e.PaisNacimiento,'MEXICO') = 'MEXICO' THEN 'M'    
			ELSE 'E' END as Nacionalidad ,    
		RTRIM(LTRIM(isnull(p.Codigo,''))) as [Codigo_Pais],    
		format(e.FechaAntiguedad,'yyyy-MM-dd') as [Fecha_Antiguedad],    
		RTRIM(LTRIM(isnull(de.Calle,''))) as Calle ,    
		RTRIM(LTRIM(isnull(de.Exterior,'SN'))) as Exterior,    
		RTRIM(LTRIM(isnull(Colonias.NombreAsentamiento,isnull(de.Colonia,'')))) as Colonia,    
		RTRIM(LTRIM(isnull(CP.CodigoPostal,isnull(de.CodigoPostal,'77710')))) as [Codigo_Postal],    
		RTRIM(LTRIM(isnull(Municipios.Descripcion,isnull(de.Municipio,'')))) as Municipio,    
		RTRIM(LTRIM(isnull(Estados.NombreEstado,isnull(de.Estado,'')))) as Estado,    
		isnull(ce.Value,'9848773500') as [Telefono_Trabajador],    
		'9848773500' as [Otro_Telefono],    
		replace(isnull(pe.Tarjeta,''),' ','')      as Tarjeta,    
		'5133' as [Sucursal_Gestora],  
		isnull(email.Value,'') as [Email],    
		ROW_NUMBER()OVER(Partition by e.ClaveEmpleado order by e.ClaveEmpleado asc) as RN  
	into #TempRegistros    
	from @dtEmpleados e    
		left join rh.tblPagoEmpleado pe WITH(NOLOCK)    
			on e.IDEmpleado = pe.IDEmpleado   
				and pe.IDLayoutPago = @IDLayout 
		left join Nomina.tblLayoutPago lp WITH(NOLOCK)  
			on lp.IDLayoutPago = pe.IDLayoutPago   
		left join Nomina.tblCatTiposLayout tl WITH(NOLOCK)    
			on lp.IDTipoLayout = tl.IDTipoLayout    

		left join [RH].[tblDireccionEmpleado] de WITH(NOLOCK)   
			on e.IDEmpleado = de.IDEmpleado  
				AND de.FechaIni<= @Fechafin and de.FechaFin >= @Fechafin  
		Left join Sat.tblCatCodigosPostales CP WITH(NOLOCK)   
			on CP.IDCodigoPostal = de.IDCodigoPostal
		Left join Sat.tblCatEstados Estados WITH(NOLOCK)   
			on de.IDEstado = Estados.IDEstado
		Left join Sat.tblCatMunicipios Municipios WITH(NOLOCK)   
			on de.IDMunicipio = Municipios.IDMunicipio
		Left join Sat.tblCatColonias Colonias WITH(NOLOCK)   
			on de.IDColonia = Colonias.IDColonia
		Left join Sat.tblCatPaises p WITH(NOLOCK) 
			on de.IDPais = p.IDPais
		Left join Sat.tblCatLocalidades Localidades WITH(NOLOCK)   
			on de.IDLocalidad = Localidades.IDLocalidad     
				  
		left join(select cce.*
				from RH.tblContactoEmpleado cce WITH(NOLOCK)    
					join rh.tblCatTipoContactoEmpleado tce WITH(NOLOCK)    
			on cce.IDTipoContactoEmpleado = tce.IDTipoContacto    
				and tce.Descripcion = 'TELÉFONO'    
				)ce on e.IDEmpleado = ce.IDEmpleado    
		left join(select cce.*
				from RH.tblContactoEmpleado cce WITH(NOLOCK)    
					join rh.tblCatTipoContactoEmpleado tce WITH(NOLOCK)    
			on cce.IDTipoContactoEmpleado = tce.IDTipoContacto    
				and tce.Descripcion = 'EMAIL'    
				) email on e.IDEmpleado = email.IDEmpleado  
		--left join [RH].[tblDireccionEmpleado] DireccionEmpleado WITH(NOLOCK)   
		--	on e.IDEmpleado = DireccionEmpleado.IDEmpleado  
		--		AND DireccionEmpleado.FechaIni<= @Fechafin and DireccionEmpleado.FechaFin >= @Fechafin  
		--Left join Sat.tblCatCodigosPostales CP WITH(NOLOCK)   
		--	on CP.IDCodigoPostal = DireccionEmpleado.IDCodigoPostal
		--Left join Sat.tblCatEstados Estados WITH(NOLOCK)   
		--	on DireccionEmpleado.IDEstado = Estados.IDEstado
		--Left join Sat.tblCatMunicipios Municipios WITH(NOLOCK)   
		--	on DireccionEmpleado.IDMunicipio = Municipios.IDMunicipio
		--Left join Sat.tblCatColonias Colonias WITH(NOLOCK)   
		--	on DireccionEmpleado.IDColonia = Colonias.IDColonia
		--Left join Sat.tblCatPaises DireccionEmpleadoPais 
		--	on DireccionEmpleado.IDPais = DireccionEmpleadoPais.IDPais
		--Left join Sat.tblCatLocalidades Localidades WITH(NOLOCK)   
		--	on DireccionEmpleado.IDLocalidad = Localidades.IDLocalidad  

	 where  pe.IDLayoutPago is not null and isnull(pe.Cuenta,'') = ''
      
	 insert into #tempResp    
	 select [App].[fnAddString](2 ,'01','0',1)     
		  + [App].[fnAddString](10,'4201148486','0',1)  
		  + [App].[fnAddString](13,'DRO070530UY4',' ',1)     
		  + [App].[fnAddString](3 ,'115','0',1)     
		  + [App].[fnAddString](10,cast(FORMAT(GETDATE(),'yyyy-MM-dd')as varchar(10)),'',1)     
		  + [App].[fnAddString](9 ,'000000001','0',1)	--Número de Secuencia
		  + [App].[fnAddString](30,'APERTURA DE CUENTAS',' ',2)   
		  + [App].[fnAddString](7 ,(select count(*) from #tempRegistros),'0',1)     
		  + [App].[fnAddString](36,'','',2)     
		  
		  
		  --+ [App].[fnAddString](11,'101','0',2)     
		  --+ [App].[fnAddString](1,'1','0',1)     
		  --+ [App].[fnAddString](12,'0','0',1)     
		  --+ [App].[fnAddString](4,'5133','0',1)     
		  --+ [App].[fnAddString](8,'0','0',1)    

 -- HEADER    
     
 --Body    
	insert into #tempResp    
	select 	
		   [App].[fnAddString](2,'02','0',1)      
		+  [App].[fnAddString](18,CURP,'',1)     
		+  [App].[fnAddString](50,rtrim(ltrim(Email)),'',2)     
		+  [App].[fnAddString](10,Telefono_Trabajador,'',1)     
		+  [App].[fnAddString](4,'0085','',1)     
		+  [App].[fnAddString](16,Tarjeta,'0',2)     
		+  [App].[fnAddString](20,'','',2)     


		--+  [App].[fnAddString](20,Nombres,'',2)     
		--+  [App].[fnAddString](20,Paterno,'',2)     
		--+  [App].[fnAddString](20,Materno,'',2)     
		--+  [App].[fnAddString](10,Fecha_Nacimiento,'',1)     
		--+  [App].[fnAddString](1,Estado_Civil,'0',1)     
		--+  [App].[fnAddString](1,Sexo,'0',1)     
		--+  [App].[fnAddString](1,Nacionalidad,'0',1)     
		--+  [App].[fnAddString](5,Codigo_Pais,'',1)     
		--+  [App].[fnAddString](3,'EPL','',1)     
		--+  [App].[fnAddString](10,Fecha_Antiguedad,'',1)     
		--+  substring([App].[fnAddString](50,Calle,'',2),1,50)     
		--+  [App].[fnAddString](16,Exterior,'',2)     
		--+  [App].[fnAddString](30,Colonia,'',2)     
		--+  [App].[fnAddString](5,Codigo_Postal,'',2)     
		--+  [App].[fnAddString](30,Municipio,'',2)     
		--+  [App].[fnAddString](25,Estado,'',2)     
		--+  [App].[fnAddString](10,Otro_Telefono,'',2)     
		--+  [App].[fnAddString](4,'0000','0',2)     
		--+  [App].[fnAddString](2,'A','',2)     
		--+  [App].[fnAddString](4,'0000','0',2)     
		--+  [App].[fnAddString](4,Sucursal_Gestora,'0',2)     
		--+  [App].[fnAddString](15,'000000000500000','0',2)     
		--+  [App].[fnAddString](1,'2','0',2)     
		--+  [App].[fnAddString](21,'0','0',2)     
		--+  [App].[fnAddString](47,'','',2)     
		--+  [App].[fnAddString](9,'A0225'+cast(Sucursal_Gestora as varchar(4)),'0',2)     
	from #tempRegistros    
	where RN = 1  
 
	select * from #tempResp    
    
END


--select * from rh.tblCatTipoContactoEmpleado
GO
