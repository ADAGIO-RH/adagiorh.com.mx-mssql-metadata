USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Reclutamiento].[spCrearCandidatoDeEmpleado]--390,290
(
	@IDEmpleado int,
	@IDUsuario int
)
AS
BEGIN
DECLARE 
		@IDCandidato int =0 
		,@IDPlaza int
		,@Nombre varchar(50) 
		,@SegundoNombre varchar(50)
		,@Paterno varchar(50)
		,@Materno varchar(50)
		,@Sexo  char(1)
		,@FechaNacimiento date
		,@IDPaisNacimiento int
		,@IDMunicipioNacimiento int
		,@IDEstadoNacimiento int
		,@IDLocalidadNacimiento int
		,@RFC varchar(50)
		,@CURP varchar(50)
		,@NSS varchar(50)
		,@IDAfore int 
		,@IDEstadoCivil int
		,@Estatura decimal(10,2)
		,@Peso decimal(10,2)
		,@Extranjero bit
		,@TipoSangre varchar(10)
		,@VacanteDeseada varchar(50)
		,@SueldoDeseado Decimal(18,2)
		,@CorreoElectronico varchar(50)
		,@Password Varchar(50)
		,@TelefonoCelular varchar(50)
		,@TelefonoFijo varchar(50)
		,@Pasaporte varchar(50)
		,@IDPaisResidencia int
		,@IDEstadoResidencia int
		,@IDMunicipioResidencia int
		,@IDLocalidadResidencia int
		,@IDCodigoPostalResidencia int
		,@IDColoniaResidencia int
		,@CalleResidencia varchar(50)
		,@NumeroExtResidencia varchar(50)
		,@NumeroIntResidencia varchar(50)

	IF NOT EXISTS( SELECT TOP 1 1 FROM Reclutamiento.tblCandidatos with(nolock) where IDEmpleado = @IDEmpleado)
	BEGIN

	BEGIN TRY  
    -- Generate divide-by-zero error.  
		BEGIN TRANSACTION TranEmpleadoACandidato;  
  
		SELECT 
			 @IDCandidato  =0 
			,@IDPlaza = 0
			,@Nombre = M.Nombre
			,@SegundoNombre = M.SegundoNombre
			,@Paterno  = M.Paterno
			,@Materno  = M.Materno
			,@Sexo	   = CASE WHEN M.Sexo = 'MASCULINO' THEN 'M' ELSE 'F' END
			,@FechaNacimiento = M.FechaNacimiento
			,@IDPaisNacimiento = M.IDPaisNacimiento
			,@IDMunicipioNacimiento = m.IDMunicipioNacimiento
			,@IDEstadoNacimiento = m.IDEstadoNacimiento
			,@IDLocalidadNacimiento = M.IDLocalidadNacimiento
			,@RFC = M.RFC
			,@CURP = M.CURP
			,@NSS = M.IMSS
			,@IDAfore  = M.IDAfore 
			,@IDEstadoCivil = M.IDEstadoCivil
			,@Estatura = s.Estatura
			,@Peso  = s.Peso
			,@Extranjero = 0
			,@TipoSangre = s.TipoSangre
			,@CorreoElectronico = u.Email
			,@Password = u.[Password]
		FROM RH.tblEmpleadosMaster m with(nolock)
			left join RH.tblSaludEmpleado S with(nolock)
				on S.IDEmpleado = m.IDEmpleado
			left join Seguridad.tblUsuarios U with(nolock)
				on U.IDEmpleado = m.IDEmpleado
		WHERE M.IDEmpleado = @IDEmpleado
	
		Select Top 1
				 @IDPaisResidencia = d.IDPais
				,@IDEstadoResidencia = d.IDEstado
				,@IDMunicipioResidencia = d.IDMunicipio
				,@IDLocalidadResidencia = d.IDLocalidad
				,@IDCodigoPostalResidencia = d.IDCodigoPostal
				,@IDColoniaResidencia = d.IDColonia
				,@CalleResidencia = d.Calle
				,@NumeroExtResidencia = d.Exterior
				,@NumeroIntResidencia = d.Interior
		from RH.tblDireccionEmpleado d with(nolock)
		WHERE IDEmpleado = @IDEmpleado
		ORDER BY d.FechaFin DESC




		select top 1 @TelefonoCelular = ce.Value 
		from RH.tblcattipoContactoEmpleado TCE with(nolock)
			inner join RH.tblContactoEmpleado CE with(nolock)
				on CE.IDTipoContactoEmpleado = TCE.IDTipoContacto
		where TCE.IDMedioNotificacion = 'Celular'
		
		select top 1 @TelefonoFijo = ce.Value 
		from RH.tblcattipoContactoEmpleado TCE with(nolock)
			inner join RH.tblContactoEmpleado CE with(nolock)
				on CE.IDTipoContactoEmpleado = TCE.IDTipoContacto
		where TCE.IDMedioNotificacion = 'TelefonoFijo'


		EXEC [Reclutamiento].[spIUCandidato]
		 @IDCandidato	
		,@IDPlaza		
		,@Nombre		
		,@SegundoNombre 
		,@Paterno		
		,@Materno		
		,@Sexo			
		,@FechaNacimiento		
		,@IDPaisNacimiento		
		,@IDMunicipioNacimiento 
		,@IDEstadoNacimiento	
		,@IDLocalidadNacimiento 
		,@RFC					
		,@CURP					
		,@NSS					
		,@IDAfore				
		,@IDEstadoCivil			
		,@Estatura				
		,@Peso					
		,@Extranjero			
		,@TipoSangre			
		--,@VacanteDeseada		
		,@SueldoDeseado			
		,@CorreoElectronico		
		,@Password				
		,@TelefonoCelular		
		,@TelefonoFijo			
		,@Pasaporte				
		,@IDPaisResidencia		
		,@IDEstadoResidencia	
		,@IDMunicipioResidencia 
		,@IDLocalidadResidencia 
		,@IDCodigoPostalResidencia  
		,@IDColoniaResidencia		
		,@CalleResidencia			
		,@NumeroExtResidencia		
		,@NumeroIntResidencia		
		,@IDEmpleado				
		,@IDUsuario  = @IDUsuario

		COMMIT TRAN TranEmpleadoACandidato
		END TRY  
		BEGIN CATCH  
		 ROLLBACK TRAN TranEmpleadoACandidato
		 select ERROR_MESSAGE ( )  
		 RAISERROR('ERROR AL CREAR EL CANDIDATO',16,1)
		END CATCH; 
	END
END
GO
