USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [PROCOM].[spIUClienteRegPatronal](
	@IDClienteRegPatronal int = 0
	,@IDCliente int = 0
	,@RegPatronal Varchar(20)
	,@RazonSocial Varchar(MAX)
	,@ActividadEconomica Varchar(MAX)
	,@RepresentanteLegal Varchar(MAX)
	,@OcupacionRepLegal Varchar(MAX)
	,@IDCodigoPostal int = null
	,@IDEstado int = null
	,@IDMunicipio int = null
	,@IDColonia int = null
	,@IDPais int = null
	,@Calle Varchar(Max) = null
	,@Exterior Varchar(255) = null 
	,@Interior Varchar(255) = null
	,@CodigoPostal Varchar(max)= null
	,@Estado Varchar(MAX)= null
	,@Municipio Varchar(max)= null
	,@Localidad varchar(max)= null
	,@Colonia Varchar(max)= null
	,@Pais Varchar(max)= null
	,@IDUsuario int	
)
AS
BEGIN
	 Declare @msj nvarchar(max) ;    
    
	DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max)

	IF(ISNULL(@IDCliente,0) = 0)    
    BEGIN    
		RETURN;    
    END  

	IF(ISNULL(@RegPatronal,'') = '')    
    BEGIN    
		RETURN;    
    END  

	IF(ISNULL(@RazonSocial,'') = '')    
    BEGIN    
		RETURN;    
    END 


	IF(@IDClienteRegPatronal = 0 or @IDClienteRegPatronal is null)    
    BEGIN        
    
		INSERT INTO Procom.tblClienteRegPatronal(
			 IDCliente
			,RegPatronal
			,RazonSocial
			,ActividadEconomica
			,RepresentanteLegal
			,OcupacionRepLegal
			,IDCodigoPostal
			,IDEstado
			,IDMunicipio
			,IDColonia
			,IDPais
			,Calle
			,Exterior
			,Interior
			,CodigoPostal
			,Estado
			,Municipio
			,Localidad
			,Colonia
			,Pais
		)    
		VALUES(
		@IDCliente
		,UPPER(@RegPatronal)
		,UPPER(@RazonSocial)
		,UPPER(@ActividadEconomica)
		,UPPER(@RepresentanteLegal)
		,UPPER(@OcupacionRepLegal)
		,CASE WHEN ISNULL(@IDCodigoPostal, 0) = 0 THEN NULL ELSE @IDCodigoPostal END
		,CASE WHEN ISNULL(@IDEstado, 0) = 0 THEN NULL ELSE @IDEstado END
		,CASE WHEN ISNULL(@IDMunicipio, 0) = 0 THEN NULL ELSE @IDMunicipio END
		,CASE WHEN ISNULL(@IDColonia, 0) = 0 THEN NULL ELSE @IDColonia END
		,CASE WHEN ISNULL(@IDPais, 0) = 0 THEN NULL ELSE @IDPais END
		,UPPER(@Calle)
		,UPPER(@Exterior)
		,UPPER(@Interior)
		,UPPER(@CodigoPostal)
		,UPPER(@Estado)
		,UPPER(@Municipio)
		,UPPER(@Localidad)
		,UPPER(@Colonia)
		,UPPER(@Pais)
		) 
		
		set @IDClienteRegPatronal = @@IDENTITY

		select @NewJSON = a.JSON from [Procom].[tblClienteRegPatronal] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDClienteRegPatronal = @IDClienteRegPatronal
		
		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Procom].[tblClienteRegPatronal]','[Procom].[spIUClienteRegPatronal]','INSERT',@NewJSON,''	

		   
    END    
    ELSE    
    BEGIN   
	
		select @OldJSON = a.JSON from [Procom].[tblClienteRegPatronal] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDClienteRegPatronal = @IDClienteRegPatronal
	 
		UPDATE [Procom].[tblClienteRegPatronal]    
		SET 
		 RegPatronal = UPPER(@RegPatronal)
		,RazonSocial = UPPER(@RazonSocial)
		,ActividadEconomica = UPPER(@ActividadEconomica)
		,RepresentanteLegal = UPPER(@RepresentanteLegal)
		,OcupacionRepLegal = UPPER(@OcupacionRepLegal)
		,IDCodigoPostal = CASE WHEN ISNULL(@IDCodigoPostal, 0) = 0 THEN NULL ELSE @IDCodigoPostal END
		,IDEstado = CASE WHEN ISNULL(@IDEstado, 0) = 0 THEN NULL ELSE @IDEstado END
		,IDMunicipio = CASE WHEN ISNULL(@IDMunicipio, 0) = 0 THEN NULL ELSE @IDMunicipio END
		,IDColonia = CASE WHEN ISNULL(@IDColonia, 0) = 0 THEN NULL ELSE @IDColonia END
		,IDPais = CASE WHEN ISNULL(@IDPais, 0) = 0 THEN NULL ELSE @IDPais END
		,Calle = UPPER(@Calle)
		,Exterior = UPPER(@Exterior)
		,Interior = UPPER(@Interior)
		,CodigoPostal = UPPER(@CodigoPostal)
		,Estado		  = UPPER(@Estado)
		,Municipio	  = UPPER(@Municipio)
		,Localidad	  = UPPER(@Localidad)
		,Colonia	  = UPPER(@Colonia)
		,Pais		  = UPPER(@Pais)
		WHERE IDCliente = @IDCliente   
		and IDClienteRegPatronal = @IDClienteRegPatronal
		
		select @NewJSON = a.JSON from [Procom].[tblClienteRegPatronal] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDClienteRegPatronal = @IDClienteRegPatronal
		
		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Procom].[tblClienteRegPatronal]','[Procom].[spIUClienteRegPatronal]','UPDATE',@NewJSON,@OldJSON
		    
    END;    

END;
GO
