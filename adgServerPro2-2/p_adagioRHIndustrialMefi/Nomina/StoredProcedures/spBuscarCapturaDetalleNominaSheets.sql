USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spBuscarCapturaDetalleNominaSheets] --476
(
--declare 
	@IDPeriodo int,
	@dtFiltros [Nomina].[dtFiltrosRH] READONLY,
	@IDEmpleado int = 0,
	@IDUsuario int
)
AS
BEGIN
	declare 
	   @IDTipoNomina int,
	   @FI date,
	   @FF date,
	   @dtEmpleado [RH].[dtEmpleados],
	   @tipoCaptura varchar(100) = ''

	select @IDTipoNomina=IDTipoNomina,@FI=FechaInicioPago, @FF=FechaFinPago 
	from Nomina.tblCatPeriodos
	where IDPeriodo=@IDPeriodo

	insert into @dtEmpleado
	Exec RH.spBuscarEmpleados 
     @FechaIni = @FI
	,@Fechafin = @FF
	,@IDUsuario = @IDUsuario
	,@IDTipoNomina = @IDTipoNomina
	,@dtFiltros = @dtFiltros

	if exists(select 1 from @dtFiltros where Catalogo = 'TipoCaptura')
	BEGIN
		select top 1 @tipoCaptura = value from @dtFiltros where Catalogo = 'TipoCaptura' 
	END

	SELECT	
		 
		   E.IDEmpleado,
		   E.ClaveEmpleado,
		   E.NOMBRECOMPLETO as NombreCompleto,
		   c.IDConcepto,
		   C.Codigo +' - '+C.Descripcion Concepto,
		   case when C.bCantidadMonto = 1 then ISNULL(dp.CantidadMonto,0)
		        when C.bCantidadDias  = 1 then ISNULL(dp.CantidadDias ,0)
			    when C.bCantidadVeces = 1 then ISNULL(dp.CantidadVeces,0)
			    when C.bCantidadOtro1 = 1 then ISNULL(dp.CantidadOtro1,0)
			    when C.bCantidadOtro2 = 1 then ISNULL(dp.CantidadOtro2,0)
				else ISNULL(dp.CantidadMonto,0) end Value,
		  isnull(dp.ImporteAcumuladoTotales,0) as ImporteAcumuladoTotales
		    
	FROM Nomina.tblCatPeriodos p 
		cross join @dtEmpleado e
		cross join Nomina.tblCatConceptos c
		left join Nomina.tbldetallePeriodo dp
			on dp.IDPeriodo = p.IDPeriodo
				and dp.IDConcepto = c.IDConcepto
				and dp.IDEmpleado = e.IDEmpleado
	where p.IDPeriodo = @IDPeriodo and c.Estatus = 1 and p.Cerrado = 0
		and ((c.IDConcepto in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Conceptos'),',')) 
							or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Conceptos'))))  
							  
      and ((c.IDConcepto in (Select IDConcepto
								from Nomina.tblCatConceptos 
								where ((@tipoCaptura = 'CantidadMonto' and bCantidadMonto = 1) 
								OR (@tipoCaptura = 'CantidadDias' and bCantidadDias = 1)
								OR (@tipoCaptura = 'CantidadVeces' and bCantidadVeces = 1)
								OR (@tipoCaptura = 'CantidadOtro1' and bCantidadOtro1 = 1)
								OR (@tipoCaptura = 'CantidadOtro2' and bCantidadOtro2 = 1)))  )
							
							or (Not exists(Select 1 from @dtFiltros where Catalogo = 'TipoCaptura')))    
	ORDER BY e.IDEmpleado, C.OrdenCalculo

end


--declare 
--   @tipoCaptura varchar(100) = 'CantidadVeces'



--Select *
--								from Nomina.tblCatConceptos 
--								where ((@tipoCaptura = 'CantidadMonto' and bCantidadMonto = 1) 
--								OR (@tipoCaptura = 'CantidadDias' and bCantidadDias = 1)
--								OR (@tipoCaptura = 'CantidadVeces' and bCantidadVeces = 1)
--								OR (@tipoCaptura = 'CantidadOtro1' and bCantidadOtro1 = 1)
--								OR (@tipoCaptura = 'CantidadOtro2' and bCantidadOtro2 = 1))
GO
