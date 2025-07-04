USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [PROCOM].[spGenerarProtocoloIX] (
	@IDProtocoloIX int,
	@IDUsuario int
)
AS
BEGIN
	SET FMTONLY OFF 

	DECLARE 
	--@IDProtocoloIX int = 1
	--,@IDUsuario int = 1
		@Direccion Varchar(max)
		,@FolioDocumental Varchar(max)
		,@Modelo Varchar(max)
		,@PEPSE Varchar(MAX)
		,@RepresentanteModelo Varchar(MAX)
		,@FechaPrograma Varchar(MAX)
		,@RazonSocialCliente Varchar(MAX)
		,@TotalProtocolo Decimal(18,2)
		,@TotalProtocoloLetra Varchar(max)
		,@MesAnio Varchar(max)
		,@MesAnioNumero Varchar(max)
		,@RepresentanteDatosConstitutivos Varchar(max)
		,@CoordinadorComisionMixta Varchar(max)

		,@IDCliente int
		,@IDClienteModelo int
		,@IDClienteRazonSocial int
		,@FechaIni date
		,@FechaFin date
		,@Ejercicio int
		,@IDMes int
		,@IDIdioma varchar(max)
		
			--@IDUsuario int = 1
	;
	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	if object_id('tempdb..#tempFacturas') is not null drop table #tempFacturas
	if object_id('tempdb..#tempCuotas') is not null drop table #tempCuotas

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

		IF((select top 1 CEC.Descripcion from Procom.tblClienteEstatus CE with(nolock)
			inner join Procom.tblCatEstatusCliente CEC with(nolock)
				on CE.IDCatEstatusCliente = CEC.IDCatEstatusCliente
			WHERE CE.IDCliente = @IDCliente) <> 'Activo')
		BEGIN
			RAISERROR('El Cliente de este protocolo no esta en estatus activo',16,1)
			RETURN;
		END


		select CCA.IDCliente
			,CCA.Descripcion
			,CCA.Cuota
			,CCA.Anio
			,CCA.FechaVigencia
			,DATEADD(YEAR,1,CCA.FechaVigencia)FechaFinVigencia
			,CCAE.FechaHora
			,CECA.Descripcion as Estatus
			,CECA.LayoutDescargable
			,CCA.IDClienteCuotaAfiliacion
			, ROW_NUMBER()OVER(Partition by CCA.IDClienteCuotaAfiliacion order by CCAE.FechaHora desc) RN
			into #tempCuotas
		from Procom.tblClienteCuotaAfiliacion CCA with(nolock)
			inner join Procom.tblClienteCuotaAfiliacionEstatus CCAE with(nolock)
				on CCA.IDClienteCuotaAfiliacion = CCAE.IDClienteCuotaAfiliacion
			inner join Procom.tblCatEstatusCuotaAfiliacion CECA with(nolock)
				on CECA.IDCatEstatusCuotaAfiliacion = CCAE.IDCatEstatusCuotaAfiliacion
		WHERE CCA.IDCliente = @IDCliente
	
		DELETE #tempCuotas 
		WHERE RN > 1

		IF((Select COUNT(*) FROM #tempCuotas) = 0)
		BEGIN
			RAISERROR('El Cliente de este protocolo No tiene historial de Cuotas, en caso de que no aplique, crear una cuota para este cliente con estatus de NO APLICA',16,1)
			RETURN;
		END

		IF(EXISTS(SELECT Top 1 1 FROM #tempCuotas WHERE LayoutDescargable = 0))
		BEGIN
			RAISERROR('El Cliente de este protocolo tiene cuotas pendientes o en estatus NO DESCARGABLE para Protocolo IX.',16,1)
			RETURN;
		END

		--IF(NOT EXISTS(SELECT Top 1 1 FROM #tempCuotas WHERE Anio = @Ejercicio))
		--BEGIN
		--	RAISERROR('El Cliente de este protocolo no tiene cuotas para el año ',16,1)
		--	RETURN;
		--END

		IF(NOT EXISTS(SELECT Top 1 1 FROM #tempCuotas WHERE (@FechaIni between FechaVigencia and FechaFinVigencia) or (@FechaFin between FechaVigencia and FechaFinVigencia)))
		BEGIN
			RAISERROR('El Protocolo IX que desea generar esta fuera de la cobertura de las cuotas',16,1)
			RETURN;
		END

		select
			@MesAnio  = CONCAT(JSON_VALUE(m.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')),' ', CAST(@Ejercicio as VARCHAR(4)))
			,@MesAnioNumero =  CONCAT([App].[fnAddString](2,CAST(@IDMes as varchar(2)),'0',1),'-',CAST( @Ejercicio AS VARCHAR(4)))
		from Nomina.tblCatMeses M with(nolock)
		WHERE m.IDMes = @IDMes

		SELECT 
		@Direccion = CONCAT('En la alcaldía de ',Muni.Descripcion,', ',Est.NombreEstado,', siendo las ', FORMAT(getdate(), 'HH:mm', 'es-ES'),' horas del día ',FORMAT(@FechaFin, 'dd "de" MMMM "de" yyyy', 'es-ES'),', en el domicilio de la fuente de trabajo ubicado en ',CRS.Calle,', número ',CRS.Exterior,', ',CRS.Interior,', colonia ',C.NombreAsentamiento,', ',Muni.Descripcion,', ',Est.NombreEstado,', código postal ',CP.CodigoPostal,',')
		,@RazonSocialCliente = CRS.RazonSocial
		FROM Procom.tblClienteRazonSocial CRS with(nolock)
			inner join SAT.tblCatPaises P with(nolock)
				on CRS.IDPais = P.IDPais
			inner join Sat.tblCatEstados Est with(nolock)
				on Est.IDEstado = CRS.IDEstado
			inner join SAT.tblCatMunicipios Muni with(nolock)
				on Muni.IDMunicipio = CRS.IDMunicipio
			inner join Sat.tblCatColonias C with(nolock)
				on C.IDColonia = CRS.IDColonia
			inner join SAT.tblCatCodigosPostales CP with(nolock)
				on CP.IDCodigoPostal = CRS.IDCodigoPostal
		WHERE CRS.IDClienteRazonSocial = @IDClienteRazonSocial

		SELECT @PEPSE = DEC.Valor 
		FROM RH.tblCatDatosExtraClientes CDEC with(nolock)
			INNER JOIN RH.tblDatosExtraClientes DEC with(nolock)
				on DEC.IDCatDatoExtraCliente = CDEC.IDCatDatoExtraCliente
				and DEC.IDCliente = @IDCliente
		WHERE CDEC.Nombre = 'PEPSE'
	
		SELECT @FolioDocumental = DEC.Valor 
		FROM RH.tblCatDatosExtraClientes CDEC with(nolock)
			INNER JOIN RH.tblDatosExtraClientes DEC with(nolock)
				on DEC.IDCatDatoExtraCliente = CDEC.IDCatDatoExtraCliente
				and DEC.IDCliente = @IDCliente
		WHERE CDEC.Nombre = 'DOCUMENTAL'

		SELECT @FechaPrograma = FORMAT(CONVERT(DATE, DEC.Valor, 103), 'dd "de" MMMM "de" yyyy', 'es-ES')
		FROM RH.tblCatDatosExtraClientes CDEC with(nolock)
			INNER JOIN RH.tblDatosExtraClientes DEC with(nolock)
				on DEC.IDCatDatoExtraCliente = CDEC.IDCatDatoExtraCliente
				and DEC.IDCliente = @IDCliente
		WHERE CDEC.Nombre = 'FECHAPROGRAMA'

		select @Modelo =  VDE.Valor
		from App.tblCatDatosExtras CDE with(nolock)
			inner join app.tblValoresDatosExtras VDE with(nolock)
				on CDE.IDDatoExtra = VDE.IDDatoExtra
			inner join Procom.tblClienteModelos CM with(nolock)
				on CM.IDClienteModelo = @IDClienteModelo
				and CM.IDCliente = @IDCliente
				and CM.IDEmpresa = VDE.IDReferencia
		WHERE JSON_VALUE(CDE.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Nombre')) = 'RAZON SOCIAL COMPLETA'
		AND CDE.IDTipoDatoExtra = 'razonesSociales'


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
	
		SELECT @CoordinadorComisionMixta = MCM.NombreCompleto
		FROM Procom.tblClienteComisionMixta CCM with(nolock)
			inner join Procom.tblMiembrosComisionMixta MCM with(nolock)
				on CCM.IDClienteComisionMixta = MCM.IDClienteComisionMixta
			inner join Procom.TblCatTipoMiembroComisionMixta CTMCM with(nolock)
				on CTMCM.IDCatTipoMiembroComisionMixta = MCM.IDCatTipoMiembroComisionMixta
				and CTMCM.Descripcion = 'Coordinador'
		WHERE CCM.IDCliente = @IDCliente
			and CCM.FechaIni<= @FechaFin and CCM.FechaFin >= @FechaFin
		

		select @RepresentanteDatosConstitutivos = REPLACE(substring(UPPER((COALESCE(CDC.RepresentanteNombre,''))+' '+TRIM(COALESCE(CDC.RepresentantePaterno,''))+' '+ TRIM(CASE WHEN ISNULL(CDC.RepresentanteMaterno,'') <> '' THEN ' '+COALESCE(CDC.RepresentanteMaterno,'') ELSE '' END) ),1,100 ),'  ',' ')
		FROM Procom.tblClienteDatosConstitutivos CDC with(nolock)
		WHERE CDC.IDCliente = @IDCliente
		and CDC.Vigente = 1

		select F.IDFactura,F.Folio,F.RFC,F.RazonSocial,F.Total, isnull(F.Consolidado,0) Conciliado
			into #tempFacturas
		from Procom.tblClienteRazonSocial CRS with(nolock)
			inner join Procom.TblFacturas F with(nolock)
				on CRS.RFC = F.RFC
		WHERE CRS.IDClienteRazonSocial = @IDClienteRazonSocial
		and F.Fecha BETWEEN @FechaIni and @FechaFin

		IF EXISTS(Select Top 1 1 from #tempFacturas where isnull(Conciliado,0) = 0)
		BEGIN
			Declare @MensajeFacturas Varchar(MAX)
			select @MensajeFacturas = 'Existe Facturas para este cliente que no estan consolidadas. ('+STRING_AGG(Folio, ',')+')' 
			FROM #tempFacturas 
			where isnull(Conciliado,0) = 0

			RAISERROR(@MensajeFacturas,16,1)
			RETURN;
		END


		SELECT @TotalProtocolo = SUM(Total)
		FROM #tempFacturas

		SELECT @TotalProtocoloLetra = [Utilerias].[fnConvertNumerosALetrasPesos](@TotalProtocolo)


		IF(TRIM(ISNULL(@Direccion,'')) = '')
		BEGIN
			RAISERROR('El Dirección de la Razón Social del Cliente en el Módulo de Activación no se ha capturado.',16,1)
			RETURN;
		END
		IF(TRIM(ISNULL(@PEPSE,'')) = '')
		BEGIN
			RAISERROR('El Folio PEPSE de este cliente no se ha capturado.',16,1)
			RETURN;
		END
		IF(TRIM(ISNULL(@FolioDocumental,'')) = '')
		BEGIN
			RAISERROR('El Folio Documental de este cliente no se ha capturado.',16,1)
			RETURN;
		END
		IF(TRIM(ISNULL(@FechaPrograma,'')) = '')
		BEGIN
			RAISERROR('La fecha del Programa de este cliente no se ha capturado.',16,1)
			RETURN;
		END
		IF(TRIM(ISNULL(@Modelo,'')) = '')
		BEGIN
			RAISERROR('La RAZON SOCIAL COMPLETA del Modelo(Razon social) de este cliente no se ha capturado.',16,1)
			RETURN;
		END
		IF(TRIM(ISNULL(@CoordinadorComisionMixta,'')) = '')
		BEGIN
			RAISERROR('La Comisión Mixta de este cliente no tiene capturado un Coordinador.',16,1)
			RETURN;
		END

		IF(TRIM(ISNULL(@RepresentanteDatosConstitutivos,'')) = '')
		BEGIN
			RAISERROR('Los datos Constitutivos de este cliente no tiene capturado un Representante legal.',16,1)
			RETURN;
		END

		

		SELECT
			@IDProtocoloIX  as IDProtocoloIX
			,@IDCliente AS IDCliente				
			,@IDClienteModelo as IDClienteModelo		
			,@IDClienteRazonSocial	as IDClienteRazonSocial
			,UPPER(@RazonSocialCliente) as RazonSocialCliente
			,@FechaIni	as FechaIni			
			,@FechaFin	as FechaFin			
			,@Ejercicio as Ejercicio				
			,@IDMes	as IDMes	
			,@MesAnio as MesAnio
			,@MesAnioNumero as MesAnioNumero
			,@Direccion as Direccion
			,UPPER(@PEPSE) as Pepse
			,@FolioDocumental as FolioDocumental
			,@FechaPrograma as FechaPrograma
			,UPPER(@Modelo) as Modelo
			,UPPER(@RepresentanteModelo) as RepresentanteModelo
			,UPPER(@CoordinadorComisionMixta) as CoordinadorComisionMixta
			,UPPER(@RepresentanteDatosConstitutivos) as RepresentanteDatosConstitutivos
			,@TotalProtocolo as TotalProtocolo
			,@TotalProtocoloLetra as TotalProtocoloLetra
END
GO
