USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- EXEC Procom.spGenerarProtocoloIXListaEmpleados 1,1
CREATE PROCEDURE Procom.spGenerarProtocoloIXListaEmpleados  (
	@IDProtocoloIX int,
	@IDUsuario int
)
AS
BEGIN
	SET FMTONLY OFF 
	DECLARE 
	     @IDCliente int
		,@IDClienteModelo int
		,@IDClienteRazonSocial int
		,@FechaIni date
		,@FechaFin date
		,@Ejercicio int
		,@IDMes int
		,@IDIdioma varchar(max)
		;


		if object_id('tempdb..#tempEmpleadosFacturas') is not null drop table #tempEmpleadosFacturas

		SELECT 
			 @IDCliente				 = 	p.IDCliente				
			,@IDClienteModelo		 = 	p.IDClienteModelo		
			,@IDClienteRazonSocial	 = 	p.IDClienteRazonSocial	
			,@FechaIni				 = 	p.FechaIni				
			,@FechaFin				 = 	p.FechaFin				
			,@Ejercicio				 = 	p.Ejercicio				
			,@IDMes					 = 	p.IDMes					
		FROM Procom.tblProtocoloIX P with(nolock)
		WHERE IDProtocoloIX = @IDProtocoloIX

		select M.NOMBRECOMPLETO as NombreCompleto
			,STRING_AGG(F.Folio, ',') as Facturas
			--into #tempEmpleadosFacturas
		from Procom.tblClienteRazonSocial CRS with(nolock)
			inner join Procom.TblFacturas F with(nolock)
				on CRS.RFC = F.RFC
			inner join Procom.TblFacturasPeriodos FP with(nolock)
				on FP.IDFactura = F.IDFactura
			inner join Nomina.tblHistorialesEmpleadosPeriodos HEP with(nolock)
				on HEP.IDPeriodo = FP.IDPeriodo
			inner join RH.tblEmpleadosMaster M with(nolock)
				on M.IDEmpleado = HEP.IDEmpleado
		WHERE CRS.IDClienteRazonSocial = @IDClienteRazonSocial
		and F.Fecha BETWEEN @FechaIni and @FechaFin
		GROUP BY M.NOMBRECOMPLETO
		
END
GO
