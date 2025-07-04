USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [PROCOM].[spSugererirPeriodosFacturaRanking](
	@IDFactura int
	,@IDUsuario int
)
AS
BEGIN
	DECLARE @Total Decimal(18,2),
			@Fecha date,
			@RFC VArchar(20),
			@IDIdioma varchar(max)
			--@IDUsuario int = 1
	;
	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')
	
	SELECT Top 1 
		@Total = Total,
		@RFC = RFC,
		@Fecha = Fecha
	from Procom.TblFacturas with(nolock)
	where IDFactura = @IDFactura

	IF OBJECT_ID('tempdb..#tempResponse') IS NOT NULL DROP TABLE #tempResponse


	SELECT  p.IDPeriodo,
		p.ClavePeriodo,
		p.Descripcion as PeriodoDescripcion,
		p.FechaInicioPago,
		p.FechaFinPago,
		[Procom].[fnTotalPeriodo](p.IDPeriodo) TotalPeriodo,
		TN.IDTipoNomina,
		TN.Descripcion as TipoNomina,
		c.IDCliente,
		JSON_VALUE(c.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'NombreComercial')) as Cliente,
		Ranking = 
			CASE WHEN isnull(@Total,0) - ([Procom].[fnTotalPeriodo](p.IDPeriodo)) between (-1.00) and (1.00) THEN 1 ELSE 0 END  +
			CASE WHEN @Fecha = p.FechaFinPago THEN 1 ELSE 0 END +
			CASE WHEN p.IDPeriodo in (Select IDPeriodo from Procom.tblFacturasPeriodos with(nolock)) THEN 0 ELSE 1 END 

		
		into #tempResponse
	FROM 
		Procom.tblClienteRazonSocial CRS with(nolock)
		inner join Nomina.tblCatTipoNomina TN  with(nolock)
			on CRS.IDCliente = TN.IDCliente
		inner join RH.tblCatClientes c with(nolock)
			on c.IDCliente = TN.IDCliente
		inner join Nomina.tblCatPeriodos p with(nolock)
			on TN.IDTipoNomina = p.IDTipoNomina
			and p.Cerrado = 1
	WHERE CRS.RFC = @RFC
	and p.IDPeriodo not in  (Select IDPeriodo from Procom.tblFacturasPeriodos with(nolock) where IDFactura = @IDFactura)


	SELECT top 50 * 
	FROM #tempResponse
	ORDER BY Ranking desc
	
END
GO
