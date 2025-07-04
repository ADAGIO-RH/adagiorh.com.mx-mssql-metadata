USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE Procom.spGenerarProtocoloIXFirmas(
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
		,@RepresentanteModelo Varchar(MAX)
		,@RepresentanteDatosConstitutivos Varchar(Max)
	
	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

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

	if object_id('tempdb..#tempFirmas') is not null drop table #tempFirmas

	CREATE TABLE #tempFirmas(
		IDFirma int not null identity(1,1),
		NombreCompleto Varchar(max),
		Puesto Varchar(MAX)
	)




	select @RepresentanteModelo =  VDE.Valor
		from App.tblCatDatosExtras CDE with(nolock)
			inner join app.tblValoresDatosExtras VDE with(nolock)
				on CDE.IDDatoExtra = VDE.IDDatoExtra
			inner join Procom.tblClienteModelos CM with(nolock)
				on CM.IDClienteModelo = @IDClienteModelo
				and CM.IDCliente = @IDCliente
				and CM.IDEmpresa = VDE.IDReferencia
		WHERE JSON_VALUE(CDE.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Nombre')) = 'REPRESENTANTE LEGAL'
		AND CDE.IDTipoDatoExtra = 'razonesSociales'

		select @RepresentanteDatosConstitutivos = REPLACE(substring(UPPER((COALESCE(CDC.RepresentanteNombre,''))+' '+TRIM(COALESCE(CDC.RepresentantePaterno,''))+' '+ TRIM(CASE WHEN ISNULL(CDC.RepresentanteMaterno,'') <> '' THEN ' '+COALESCE(CDC.RepresentanteMaterno,'') ELSE '' END) ),1,100 ),'  ',' ')
		FROM Procom.tblClienteDatosConstitutivos CDC with(nolock)
		WHERE CDC.IDCliente = @IDCliente
		and CDC.Vigente = 1
	
	INSERT INTO #tempFirmas(NombreCompleto,Puesto)
	Values (@RepresentanteDatosConstitutivos,'Representante legal de LA EMPRESA')
		,(@RepresentanteModelo,'Representante legal de LA ADMINISTRADORA')

		INSERT INTO #tempFirmas(NombreCompleto,Puesto)
		SELECT MCM.NombreCompleto,CTMCM.Descripcion + ' de la Comisión Mixta de Productividad Capacitación y Adiestramiento' 
		FROM Procom.tblClienteComisionMixta CCM with(nolock)
			inner join Procom.tblMiembrosComisionMixta MCM with(nolock)
				on CCM.IDClienteComisionMixta = MCM.IDClienteComisionMixta
			inner join Procom.TblCatTipoMiembroComisionMixta CTMCM with(nolock)
				on CTMCM.IDCatTipoMiembroComisionMixta = MCM.IDCatTipoMiembroComisionMixta
		WHERE CCM.IDCliente = @IDCliente
			and CCM.FechaIni<= @FechaFin and CCM.FechaFin >= @FechaFin


	SELECT * FROM #tempFirmas

END
GO
