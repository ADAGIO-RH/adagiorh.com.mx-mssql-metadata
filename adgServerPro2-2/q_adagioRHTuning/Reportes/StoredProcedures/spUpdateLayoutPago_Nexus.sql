USE [q_adagioRHTuning]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Reportes].[spUpdateLayoutPago_Nexus](
  @dtFiltros Nomina.dtFiltrosRH readonly    
  ,@IDLayoutPago int
  
) as    
    
declare 
--	@empleados [RH].[dtEmpleados]        
	 @Afectar Varchar(10) = 'FALSE'
	 ,@TipoLayoutPago  Varchar(100)
;    
 	SELECT @IDLayoutPago = cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDLayoutPago'),',')
	
 --set @Afectar = case when exists (Select top 1 cast(item as varchar(10)) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Afectar'),',')) THEN (Select top 1 cast(item as Varchar(10)) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Afectar'),','))  
	--				  else 'FALSE' 
	--				END  
	SELECT
		@TipoLayoutPago = LP.Descripcion
	FROM Nomina.tblLayoutPago LP WITH(NOLOCK)
		--inner join Nomina.tblcatTiposLayout TL WITH(NOLOCK) on LP.IDTipoLayout = TL.IDTipoLayout
	WHERE LP.IDLayoutPago = @IDLayoutPago

	IF(@TipoLayoutPago NOT LIKE '%SANTANDER%' )
	BEGIN
		RAISERROR('El layout seleccionado no corresponde con los datos requeridos para la alta masiva.',16,1)
		RETURN ;
	END
	
  
 -- /* Se buscan todos los empleados vigentes del tipo de nómina seleccionado */        
    --insert into @empleados        
    --exec [RH].[spBuscarEmpleados]   


	
			if object_id('tempdb..#TempDatosAfectar') is not null
				drop table #TempDatosAfectar



	select
		  Empleados.IDEmpleado
		, Empleados.ClaveEmpleado as [Clave]
		, Empleados.NOMBRECOMPLETO as [NOMBRE COMPLETO]
		, depto.Codigo +' - '+ depto.Descripcion as [DEPTO]
		, Suc.Codigo +' - '+ Suc.Descripcion as [SUCURSAL]
		,'Cambió a'+ cast(@TipoLayoutPago as varchar(100)) as [CAMBIOLAYOUT]
	
		into #TempDatosAfectar
	from rh.tblEmpleadosMaster Empleados
		left join RH.tblCatDepartamentos depto with(nolock)
			on Empleados.IDDepartamento = depto.IDDepartamento
		left join RH.tblCatSucursales Suc with(nolock)
			on Empleados.IDSucursal = Suc.IDSucursal
		left join RH.tblCatPuestos Puestos with(nolock)
			on Empleados.IDPuesto = Puestos.IDPuesto
		left join RH.tblCatTiposPrestaciones TP with(nolock)
			on tp.IDTipoPrestacion = Empleados.IDTipoPrestacion
		left join RH.tblPagoEmpleado pe on pe.IDEmpleado = Empleados.IDEmpleado where IDLayoutPago=1--on Nomina.tblLayoutPago lp 
	ORDER BY Empleados.ClaveEmpleado ASC
	SELECT 
		[Clave]
		, [NOMBRE COMPLETO]
		, [DEPTO]
		, [SUCURSAL]
		, [CAMBIOLAYOUT]
	
	FROM #TempDatosAfectar
	ORDER BY Clave ASC

	IF(@Afectar = 'TRUE')
	BEGIN

	PRINT 'HOLA'
		--MERGE Nomina.tblDetallePeriodo AS TARGET
		--USING #TempDatosAfectar AS SOURCE
		--	ON TARGET.IDPeriodo = @IDPeriodoInicial
		--		and TARGET.IDConcepto = @IDConceptoAguinaldo
		--		and TARGET.IDEmpleado = SOURCE.IDEmpleado
		--WHEN MATCHED Then
		--	update
		--		Set TARGET.CantidadMonto  = isnull(SOURCE.[IMPORTE AGUINALDO] ,0)  

		--WHEN NOT MATCHED BY TARGET THEN 
		--	INSERT(IDEmpleado,IDPeriodo,IDConcepto, CantidadMonto)  
		--	VALUES(SOURCE.IDEmpleado,@IDPeriodoInicial,@IDConceptoAguinaldo,  
		--	isnull(SOURCE.[IMPORTE AGUINALDO] ,0)
		--	)
		--;
	END

GO
