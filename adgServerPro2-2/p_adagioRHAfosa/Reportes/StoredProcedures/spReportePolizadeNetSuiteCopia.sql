USE [p_adagioRHAfosa]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--select * from Nomina.tblCatPeriodos where Descripcion like '%19-06%'

CREATE PROCEDURE [Reportes].[spReportePolizadeNetSuiteCopia](
	@dtFiltros Nomina.dtFiltrosRH readonly    
	,@IDUsuario int    
) as    

	--declare @IDUsuario int = 1
	--declare @dtFiltros  Nomina.dtFiltrosRH
	--insert into @dtFiltros  values(N'Ejercicio',N'2021')
	--insert into @dtFiltros  values(N'IDPeriodoInicial',N'100')
	--insert into @dtFiltros  values(N'Clientes',N'2')
	--insert into @dtFiltros  values(N'Cliente',N'2')
	--insert into @dtFiltros  values(N'TipoNomina',N'5')
	--insert into @dtFiltros  values(N'IDUsuario',N'1')

	declare @tempPercepcionesExentas as table (
		CodigoPercepcion varchar(20),
		CodigoExento varchar(20)
	)

	insert @tempPercepcionesExentas
	values('130', '405') -- EXENTO AGUINALDO	
		 ,('121', '404') -- EXENTO- PRIMA VACACIONAL	
		 ,('119', '403') -- EXENTO PRIMA DOMINICAL	
		 ,('132', '407') -- EXENTO INDEMIZACION (90 DIAS)	
		 ,('133', '414') -- EXENTO INDEMIZACION (20 DIAS)	
		 ,('134', '415') -- EXENTO PRIMA DE ANTIGÜEDAD	
		 ,('110', '400') -- EXENTO DE TIEMPO EXTRA	
		 ,('117', '401') -- EXENTO FESTIVO LABORADO	
         ,('118','402') -- EXENTO DESCANSO LABORADO
		 ,('123','404') -- EXENTO PRIMA VACACIONAL NO DISFRUTADA 
	declare 
		@empleados [RH].[dtEmpleados]        
		,@IDPeriodoSeleccionado int=0        
		,@periodo [Nomina].[dtPeriodos]        
		,@configs [Nomina].[dtConfiguracionNomina]        
		,@Conceptos [Nomina].[dtConceptos]        
		,@IDTipoNomina int     
		,@fechaIniPeriodo  date        
		,@fechaFinPeriodo  date		
		--,@IDUsuario int    = 1
		,@General bit 
		,@Finiquito bit 
		,@Especial bit 
	;    
  
	set @IDTipoNomina = 
		case when exists (Select top 1 cast(item as int) 
							from App.Split((Select top 1 Value 
											from @dtFiltros where Catalogo = 'TipoNomina'),',')) 
		THEN (Select top 1 cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoNomina'),','))  
		else 0  
	END  
  
  
	/* Se buscan el periodo seleccionado */    
	insert into @periodo  
	select   
		IDPeriodo  
		,IDTipoNomina  
		,Ejercicio  
		,ClavePeriodo  
		,Descripcion  
		,FechaInicioPago  
		,FechaFinPago  
		,FechaInicioIncidencia  
		,FechaFinIncidencia  
		,Dias  
		,AnioInicio  
		,AnioFin  
		,MesInicio  
		,MesFin  
		,IDMes  
		,BimestreInicio  
		,BimestreFin  
		,Cerrado  
		,General  
		,Finiquito  
		,isnull(Especial,0)  
	from Nomina.tblCatPeriodos  
	where ((IDPeriodo in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDPeriodoInicial'),','))                   
		or (Not exists(Select 1 from @dtFiltros where Catalogo = 'IDPeriodoInicial' and isnull(Value,'')<>''))))                  
    
	select top 1 @fechaIniPeriodo = FechaInicioPago,  @fechaFinPeriodo = FechaFinPago from @periodo  
	select @General = General , @Finiquito = Finiquito, @Especial = Especial from @periodo

	IF (@General = 1 or @Especial =1 )
	BEGIN 
		/* Se buscan todos los empleados vigentes del tipo de nómina seleccionado */        
		insert into @empleados        
		exec [RH].[spBuscarEmpleados] @IDTipoNomina = @IDTipoNomina,@FechaIni=@fechaIniPeriodo, @Fechafin = @fechaFinPeriodo ,@dtFiltros = @dtFiltros, @IDUsuario = @IDUsuario     
    END ELSE
	IF (@Finiquito = 1)
	BEGIN
		/* SE TRAE LOS EMPLEADOS QUE ESTÁN EN EL PERIODO PARA NO DESCARTAR LOS QUE TIENEN FECHA BAJA FUERA DE LAS DEL PERIODO*/
		insert into @empleados
		select distinct E.* 
		from rh.tblEmpleadosMaster E with (nolock)
			inner join Nomina.tblDetallePeriodo DP with (nolock) on DP.IDempleado = E.IDempleado 
			inner join @periodo P on P.IDPeriodo = DP.IDPeriodo
	END

	--select * from @empleados where claveempleado = '0502' return
    -- select * from @empleados e
    -- left join RH.tblCatDepartamentos cd	with (nolock) on e.IDDepartamento = cd.IDDepartamento
    -- return 

	select * 
	from (
		--PERCEPCIONES GRAVADAS
		Select  
			convert(varchar, getdate(), 103) as FECHA 
			,concat( cd.CuentaContable , ' ' , cd.Descripcion )  as DEPARTAMENTO
			,case when c.Codigo in ('162', '163') then CONCAT(CuentaCargo,e.ClaveEmpleado) else CuentaCargo end as CUENTA
			,0 as CREDIT
			--,SUM(dp.ImporteGravado) as DEBIT
			,CASE WHEN c.Codigo in (select CodigoPercepcion from @tempPercepcionesExentas) THEN SUM(dp.ImporteGravado) else SUM(dp.ImporteTotal1) END as DEBIT 
			--,CASE WHEN c.Codigo between '400' and '499' THEN SUM(dp.ImporteTotal1) else SUM(dp.ImporteGravado) END as DEBIT 
			--,CASE WHEN SUM(dp.ImporteGravado) > 0 THEN SUM(dp.ImporteGravado) else SUM(dp.ImporteTotal1) END as DEBIT 
			,concat(cd.Descripcion,'-',c.Codigo,'-',c.Descripcion,'-',P.Descripcion) as NOTA
		from @periodo P  
			inner join Nomina.tblDetallePeriodo dp	with (nolock) on p.IDPeriodo = dp.IDPeriodo and dp.ImporteTotal1 <> 0
			inner join Nomina.tblCatConceptos c		with (nolock) on C.IDConcepto = dp.IDConcepto and C.CuentaCargo <> ''  
			inner join Nomina.tblCatTipoConcepto tc with (nolock) on tc.IDTipoConcepto = c.IDTipoConcepto  
			inner join @empleados e on dp.IDEmpleado = e.IDEmpleado  
			inner join RH.tblCatDepartamentos cd	with (nolock) on e.IDDepartamento = cd.IDDepartamento
		where c.Codigo not in ( '309','304', '306', '180','307','301C')
			--and c.IDTipoConcepto in (1)
			--and isnull(dp.ImporteTotal1,0) > 0
			--and isnull(dp.ImporteGravado,0) > 0
		group by cd.IDDepartamento,
			c.Descripcion
			,cd.Descripcion
			,C.CuentaCargo
			,cd.Descripcion
			,c.Codigo
			,c.Descripcion
			,P.Descripcion
			,cd.CuentaContable
			,e.ClaveEmpleado

		UNION ALL

		--DEDUCIONES
		Select  
			convert(varchar, getdate(), 103) as FECHA 
			,IIF ( c.Codigo = '338', concat('8000',' ' ,'GASTOS DE OPERACIÓN' ), concat( cd.CuentaContable , ' ' , cd.Descripcion ) )  as DEPARTAMENTO
			,C.CuentaAbono as CUENTA
			,SUM(dp.ImporteTotal1) as CREDIT
			,0 as DEBIT
			,concat(cd.Descripcion,'-',c.Codigo,'-',c.Descripcion,'-',P.Descripcion) as NOTA
		from @periodo P  
			inner join Nomina.tblDetallePeriodo dp	with (nolock) on p.IDPeriodo = dp.IDPeriodo and dp.ImporteTotal1 <> 0
			inner join Nomina.tblCatConceptos c		with (nolock) on C.IDConcepto = dp.IDConcepto and C.CuentaAbono <> ''  
			inner join Nomina.tblCatTipoConcepto tc with (nolock) on tc.IDTipoConcepto = c.IDTipoConcepto  
			inner join @empleados e on dp.IDEmpleado = e.IDEmpleado  
			inner join RH.tblCatDepartamentos cd on e.IDDepartamento = cd.IDDepartamento
		where c.Codigo not in ( '309','304', '306','180','307','301C' )
		group by cd.IDDepartamento,
				c.Descripcion
			   ,cd.Descripcion
			   ,C.CuentaAbono
			   ,cd.Descripcion
			   ,c.Codigo
			   ,c.Descripcion
			   ,P.Descripcion
			   ,cd.CuentaContable

		UNION ALL

		--309 FONDO DE AHORRO EMPRESA y 304 CREDITO INFONAVIT
		Select  
			convert(varchar, getdate(), 103) as FECHA 
			,concat( cd.CuentaContable , ' ' , cd.Descripcion )  as DEPARTAMENTO
			,IIF(c.Codigo = '309'
   				,concat('204',e.ClaveEmpleado)

				,IIF(c.Codigo in ('304', '306'),
						concat('207',e.ClaveEmpleado)

						,IIF(c.Codigo = '307',
							concat('209',e.ClaveEmpleado)
								,concat('221',e.ClaveEmpleado) ) )					   
						) AS CUENTA
				,IIF(c.Codigo = '309'
   					,dp.ImporteTotal1 * 2
					, IIF (c.Codigo in ('304', '306','301C') OR c.Codigo = '307'  , dp.ImporteTotal1, 0 )
					
					) AS CREDIT

			--,IIF( c.Codigo = '180',dp.ImporteTotal1, 0 ) as DEBIT
            ,IIF( c.Codigo in ('180'),dp.ImporteTotal1, 0 ) as DEBIT
			,concat(cd.Descripcion,'-',c.Codigo,'-',c.Descripcion,'-',P.Descripcion) as NOTA
		from @periodo P  
			inner join Nomina.tblDetallePeriodo dp with (nolock) 
				on p.IDPeriodo = dp.IDPeriodo and dp.ImporteTotal1 <> 0
			inner join Nomina.tblCatConceptos c  with (nolock)
				on C.IDConcepto = dp.IDConcepto and C.CuentaAbono <> ''  
			inner join Nomina.tblCatTipoConcepto tc  with (nolock)
				on tc.IDTipoConcepto = c.IDTipoConcepto  
			inner join @empleados e
				on dp.IDEmpleado = e.IDEmpleado  
			inner join RH.tblCatDepartamentos cd on e.IDDepartamento = cd.IDDepartamento
		where c.Codigo in ( '309' , '304', '306', '180','307','301C' )

	) tbl order by DEPARTAMENTO;
GO
