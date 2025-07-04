USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [PROCOM].[spIUClienteDatosConstitutivos](
	@IDClienteDatosConstitutivos int = 0,
	@IDCliente int ,
	@RazonSocial Varchar(255) = NULL,
	@NumeroEscritura Varchar(255) = NULL,
	@FolioMercantil Varchar(255) = NULL,
	@FechaEscritura Date,
	@IDCatTipoPoder int ,
	@IDCatTipoEscritura int = 0,
	@IDCatTipoFederativo int = 0,
	@RepresentantePaterno Varchar(255) = NULL,
	@RepresentanteMaterno Varchar(255) = NULL,
	@RepresentanteNombre Varchar(255) = NULL,
	@RepresentanteRFC Varchar(255) = NULL,
	@RepresentanteCURP Varchar(255) = NULL,
	@NotarioPaterno Varchar(255) = NULL,
	@NotarioMaterno Varchar(255) = NULL,
	@NotarioNombre Varchar(255) = NULL,
	@IDEstado int = 0, 
	@IDMunicipio int = 0,
	@LugarEscrituracion Varchar(500) = NULL,
	@NumeroNotario Varchar(255) = NULL,
	@Vigente bit = 0 
	,@IDUsuario int	
)
AS
BEGIN
	 Declare @msj nvarchar(max) ;    
    
	DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max)

	IF(ISNULL(@RazonSocial,'') = '')    
    BEGIN    
		RETURN;    
    END  

	

	IF(@IDClienteDatosConstitutivos = 0 or @IDClienteDatosConstitutivos is null)    
    BEGIN      
    
		INSERT INTO Procom.tblClienteDatosConstitutivos(
			IDCliente
			,RazonSocial
			,NumeroEscritura
			,FolioMercantil
			,FechaEscritura
			,IDCatTipoPoder
			,IDCatTipoEscritura
			,IDCatTipoFederativo
			,RepresentantePaterno
			,RepresentanteMaterno
			,RepresentanteNombre
			,RepresentanteRFC
			,RepresentanteCURP
			,NotarioPaterno
			,NotarioMaterno
			,NotarioNombre
			,IDEstado
			,IDMunicipio
			,LugarEscrituracion
			,NumeroNotario
			,Vigente
		)    
		VALUES(
			 @IDCliente
			,upper(@RazonSocial)
			,@NumeroEscritura
			,@FolioMercantil
			,@FechaEscritura
			,CASE WHEN ISNULL(@IDCatTipoPoder     ,0) = 0 THEN NULL ELSE @IDCatTipoPoder      END
			,CASE WHEN ISNULL(@IDCatTipoEscritura ,0) = 0 THEN NULL ELSE @IDCatTipoEscritura  END
			,CASE WHEN ISNULL(@IDCatTipoFederativo,0) = 0 THEN NULL ELSE @IDCatTipoFederativo END
			,upper(@RepresentantePaterno)
			,upper(@RepresentanteMaterno)
			,upper(@RepresentanteNombre	)
			,upper(@RepresentanteRFC	)
			,upper(@RepresentanteCURP	)
			,upper(@NotarioPaterno		)
			,upper(@NotarioMaterno		)
			,upper(@NotarioNombre		)
			,CASE WHEN ISNULL(@IDEstado,0) = 0 THEN NULL ELSE @IDEstado END
			,CASE WHEN ISNULL(@IDMunicipio,0) = 0 THEN NULL ELSE @IDMunicipio END
			,upper(@LugarEscrituracion)
			,@NumeroNotario
			,ISNULL(@Vigente,0)
		) 
		
		set @IDClienteDatosConstitutivos = @@IDENTITY

		select @NewJSON = a.JSON from [Procom].[tblClienteDatosConstitutivos] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDClienteDatosConstitutivos = @IDClienteDatosConstitutivos
		
		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Procom].[tblClienteDatosConstitutivos]','[Procom].[spIUClienteDatosConstitutivos]','INSERT',@NewJSON,''	

    END    
    ELSE    
    BEGIN   
	
		select @OldJSON =  a.JSON from [Procom].[tblClienteDatosConstitutivos] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDClienteDatosConstitutivos = @IDClienteDatosConstitutivos
	 
		UPDATE [Procom].[tblClienteDatosConstitutivos]    
		SET 
		  RazonSocial			= upper(@RazonSocial)
		 ,NumeroEscritura		= @NumeroEscritura
		 ,FolioMercantil		= @FolioMercantil
		 ,FechaEscritura		= @FechaEscritura
		 ,IDCatTipoPoder		= CASE WHEN ISNULL(@IDCatTipoPoder     ,0) = 0 THEN NULL ELSE @IDCatTipoPoder      END
		 ,IDCatTipoEscritura	= CASE WHEN ISNULL(@IDCatTipoEscritura ,0) = 0 THEN NULL ELSE @IDCatTipoEscritura  END
		 ,IDCatTipoFederativo	= CASE WHEN ISNULL(@IDCatTipoFederativo,0) = 0 THEN NULL ELSE @IDCatTipoFederativo END
		 ,RepresentantePaterno	= upper(@RepresentantePaterno)
		 ,RepresentanteMaterno	= upper(@RepresentanteMaterno)
		 ,RepresentanteNombre	= upper(@RepresentanteNombre )
		 ,RepresentanteRFC		= upper(@RepresentanteRFC )
		 ,RepresentanteCURP		= upper(@RepresentanteCURP )
		 ,NotarioPaterno		= upper(@NotarioPaterno		 )
		 ,NotarioMaterno		= upper(@NotarioMaterno		 )
		 ,NotarioNombre			= upper(@NotarioNombre		 )
		 ,IDEstado				= CASE WHEN ISNULL(@IDEstado,0) = 0 THEN NULL ELSE @IDEstado END
		 ,IDMunicipio			= CASE WHEN ISNULL(@IDMunicipio,0) = 0 THEN NULL ELSE @IDMunicipio END
		 ,LugarEscrituracion	= upper(@LugarEscrituracion)
		 ,NumeroNotario			= @NumeroNotario
		 ,Vigente				= ISNULL(@Vigente,0)
		WHERE IDCliente = @IDCliente   
		and IDClienteDatosConstitutivos = @IDClienteDatosConstitutivos
		
		select @NewJSON = a.JSON from [Procom].[tblClienteDatosConstitutivos] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDClienteDatosConstitutivos = @IDClienteDatosConstitutivos
		
		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Procom].[tblClienteDatosConstitutivos]','[Procom].[spIUClienteDatosConstitutivos]','UPDATE',@NewJSON,@OldJSON
		    
    END;    
END;
GO
