USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [Reportes].[spBuscarCajaAhorroPoliAcero] (
	@dtFiltros [Nomina].[dtFiltrosRH] Readonly,
	@IDUsuario int
)
AS
BEGIN
	
	DECLARE  
		@IDIdioma Varchar(5)        
	   ,@IdiomaSQL varchar(100) = null
	;   

	select 
		top 1 @IDIdioma = dp.Valor        
	from Seguridad.tblUsuarios u with (nolock)       
		Inner join App.tblPreferencias p with (nolock)        
			on u.IDPreferencia = p.IDPreferencia        
		Inner join App.tblDetallePreferencias dp with (nolock)        
			on dp.IDPreferencia = p.IDPreferencia        
		Inner join App.tblCatTiposPreferencias tp with (nolock)        
			on tp.IDTipoPreferencia = dp.IDTipoPreferencia        
	where u.IDUsuario = @IDUsuario and tp.TipoPreferencia = 'Idioma'        
        
	select @IdiomaSQL = [SQL]        
	from app.tblIdiomas with (nolock)        
	where IDIdioma = @IDIdioma        
        
	if (@IdiomaSQL is null or len(@IdiomaSQL) = 0)        
	begin        
		set @IdiomaSQL = 'Spanish' ;        
	end        
          
	SET LANGUAGE @IdiomaSQL;   

	Declare 
			@dtEmpleados [RH].[dtEmpleados]
			,@IDTipoNomina int
			,@IDTipoVigente int
			,@Titulo VARCHAR(MAX) 
			,@FechaIni date 
			,@FechaFin date 
			,@ClaveEmpleadoInicial varchar(255)
			,@ClaveEmpleadoFinal varchar(255)
			,@TipoNomina Varchar(max)

			,@CodigoConceptoCajaAhorro varchar(10) = '320'
			,@CodigoConceptoDevolucionCajaAhorro varchar(10) = '529'
			,@CodigoConceptoPrestamosCajaAhorro varchar(10) = '146'
	
	select @TipoNomina = CASE WHEN ISNULL(Value,'') = '' THEN '0' ELSE  Value END
		from @dtFiltros where Catalogo = 'TipoNomina'

	select @ClaveEmpleadoInicial = CASE WHEN ISNULL(Value,'') = '' THEN '0' ELSE  Value END
		from @dtFiltros where Catalogo = 'ClaveEmpleadoInicial'
	select @ClaveEmpleadoFinal = CASE WHEN ISNULL(Value,'') = '' THEN 'ZZZZZZZZZZZZZZZZZZZZ' ELSE  Value END
		from @dtFiltros where Catalogo = 'ClaveEmpleadoInicial'

	select @FechaIni = CAST(CASE WHEN ISNULL(Value,'') = '' THEN '1900-01-01' ELSE  Value END as date)
		from @dtFiltros where Catalogo = 'FechaIni'
	select @FechaFin = CAST(CASE WHEN ISNULL(Value,'') = '' THEN '9999-12-31' ELSE  Value END as date)
		from @dtFiltros where Catalogo = 'FechaFin'

	insert into @dtEmpleados
	Exec [RH].[spBuscarEmpleados] @IDTipoNomina=@IDTipoNomina,@EmpleadoIni=@ClaveEmpleadoInicial,@EmpleadoFin=@ClaveEmpleadoFinal,@FechaIni = @FechaIni, @FechaFin = @FechaFin, @dtFiltros = @dtFiltros,@IDUsuario=@IDUsuario			
			
			select
			 dca.ClaveEmpleado AS [CLAVE EMPLEADO]
			,dca.NOMBRECOMPLETO AS [NOMBRE]
			,dca.Monto AS [MONTO]
			,dca.Catalogo AS [ESTATUS]
			,TotalAcumuladoCajaAhorro - TotalDevolucionesCajaAhorro	as [ACUMULADO HOY]
			,TotalAcumuladoCajaAhorro	 as [TOTAL APORTACIONES]
			,TotalDevolucionesCajaAhorro as [TOTAL DEVUELTO]		
			,TotalDevolucionesPendientes as [DEV. PENDIENTES A DESCONTAR]
			
			from
				(select	 
				e.ClaveEmpleado 
				,e.NOMBRECOMPLETO 
				,ca.Monto
				,cg.Catalogo 
				,(select isnull(sum(ImporteTotal1),0) from [Nomina].[fnObtenerAcumuladoRangoFecha] (e.IDEmpleado 
													,@CodigoConceptoCajaAhorro
													,@FechaIni
													,@FechaFin)) as [TotalAcumuladoCajaAhorro]
				,(select isnull(sum(dca.Monto),0)
						from [Nomina].[tblDevolucionesCajaAhorro] dca
							join [Nomina].[tblCajaAhorro] ca on dca.IDCajaAhorro = ca.IDCajaAhorro
							join [Nomina].[tblCatPeriodos] p on dca.IDPeriodo = p.IDPeriodo and isnull(p.Cerrado,0) = 0
						where dca.IDCajaAhorro = ca.IDCajaAhorro and ca.IDEmpleado = e.IDEmpleado ) as [TotalDevolucionesPendientes]

				,(	select isnull(sum(ImporteTotal1),0)
							from [Nomina].[fnObtenerAcumuladoRangoFecha] (e.IDEmpleado ,
									@CodigoConceptoDevolucionCajaAhorro,
									@FechaIni,
									@FechaFin )) as [TotalDevolucionesCajaAhorro]


		from [Nomina].[tblCajaAhorro] ca
			join [RH].[tblEmpleadosMaster] e on ca.IDEmpleado = e.IDEmpleado
			join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on dfe.IDEmpleado = e.IDEmpleado and dfe.IDUsuario = @IDUsuario
			join [App].[tblCatalogosGenerales] cg on ca.IDEstatus = cg.IDCatalogoGeneral and cg.IDTipoCatalogo = 3) dca


END
GO
