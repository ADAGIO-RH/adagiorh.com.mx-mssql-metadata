USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc Reportes.spTestBasicos(
	@Departamentos nvarchar(max)
	,@IDUsuario int
) as

declare @empleados [RH].[dtEmpleados]    
	,@IDPeriodoSeleccionado int=0    
	,@periodo [Nomina].[dtPeriodos]    
	,@configs [Nomina].[dtConfiguracionNomina]    
	,@Conceptos [Nomina].[dtConceptos]    
	,@dtFiltros [Nomina].[dtFiltrosRH]    
	,@fechaIniPeriodo  date    
	,@fechaFinPeriodo  date    
	;

	if(isnull(@Departamentos,'')<>'')    
	BEGIN    
		insert into @dtFiltros(Catalogo,Value)    
		values('Departamentos',case when @Departamentos is null then '' else @Departamentos end)    
	END; 

  /* Se buscan todos los empleados vigentes del tipo de nómina seleccionado */    
   -- insert into @empleados    
    exec [RH].[spBuscarEmpleados] @dtFiltros = @dtFiltros, @IDUsuario = @IDUsuario
GO
