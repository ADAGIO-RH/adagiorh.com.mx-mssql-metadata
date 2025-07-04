USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Reclutamiento].[spIUExperienciaLaboral](
    @IDExperienciaLaboral int=0,
    @IDCandidato int,
    @NombreEmpresa varchar (100),
    @Cargo varchar (100),
    @FechaInicio date ,
    @FechaFin date , 
    @Descripcion VARCHAR(MAX),
    @Logros VARCHAR(250),
    @Proyectos VARCHAR(250),
    @Habilidades VARCHAR(250),
    @IDPais int = null, 
    @IDEstado int = null, 
    @IDMunicipio int = null, 
    @IDTipoTrabajo int = null,
	@IDModalidadTrabajo int =null,
	@TrabajoActual bit = 0,
    @IDUsuario int = 0 
)
AS 
BEGIN
    	DECLARE 
		@OldJSON Varchar(Max),
		@NewJSON Varchar(Max);

	

	IF(@IDExperienciaLaboral = 0 or @IDExperienciaLaboral is null)  
	BEGIN  

		if exists(select top 1 1 from [Reclutamiento].[tblExperienciaLaboral] where IDCandidato= @IDCandidato and TrabajoActual = 1 and @TrabajoActual =1)
		BEGIN
			RAISERROR ('Ya existe un Trabajo Actual',16,1)
				RETURN 
		END
		
		if exists(select top 1 1 from [Reclutamiento].[tblExperienciaLaboral] where IDCandidato= @IDCandidato and @FechaInicio > @FechaFin)
		BEGIN
			RAISERROR ('La fecha inicial no puede ser mayor a la fecha final',16,1)
				RETURN 
		END	
		
			if exists(select top 1 1 from [Reclutamiento].[tblExperienciaLaboral] where IDCandidato= @IDCandidato and FechaInicio=@FechaInicio)
		BEGIN
			RAISERROR ('Ya Existe un Trabajo con esa Fecha',16,1)
				RETURN 
		END	

		INSERT INTO [Reclutamiento].[tblExperienciaLaboral]([IDCandidato],[NombreEmpresa],[Cargo],
		[FechaInicio],[FechaFin],[Descripcion],[Logros],[Proyectos],[Habilidades],
		[IDPais],[IDEstado],[IDMunicipio],[TrabajoActual],[IDTipoTrabajo],[IDModalidadTrabajo])
		VALUES ( 
			@IDCandidato
			,UPPER(@NombreEmpresa) 
			,UPPER(@Cargo)
			,@FechaInicio 
			,case when @TrabajoActual=0 then @FechaFin else GETDATE() end
			,UPPER(@Descripcion)
			,UPPER(@Logros)
			,UPPER(@Proyectos)			
			,UPPER(@Habilidades)		
			,CASE WHEN @IDPais			= 0	THEN NULL ELSE @IDPais			 	 END 
			,CASE WHEN @IDEstado		= 0	THEN NULL ELSE @IDEstado			 END 
			,CASE WHEN @IDMunicipio		= 0	THEN NULL ELSE @IDMunicipio			 END 		
			,@TrabajoActual
			,CASE WHEN @IDTipoTrabajo	= 0	THEN NULL ELSE @IDTipoTrabajo		 END 		
			,CASE WHEN @IDModalidadTrabajo	= 0	THEN NULL ELSE @IDModalidadTrabajo	 END 		
			
		
		)	
		    --  exec [Reclutamiento].[spBuscarExperienciaLaboral] @IDCandidato = @IDCandidato,@IDUsuario = @IDUsuario

    END
    ELSE
    BEGIN
		if exists(select top 1 1 from [Reclutamiento].[tblExperienciaLaboral] where IDCandidato= @IDCandidato and IDExperienciaLaboral!=@IDExperienciaLaboral and TrabajoActual = 1 and @TrabajoActual =1)
		BEGIN
			RAISERROR ('Ya existe un Trabajo Actual',16,1)
			RETURN 
		END
		
		if exists(select top 1 1 from [Reclutamiento].[tblExperienciaLaboral] where IDCandidato= @IDCandidato and @FechaInicio > @FechaFin)
		BEGIN
			RAISERROR ('La fecha inicial no puede ser mayor a la fecha final',16,1)
				RETURN 
		END	
		
		if exists(select top 1 1 from [Reclutamiento].[tblExperienciaLaboral] where IDCandidato= @IDCandidato and IDExperienciaLaboral!=@IDExperienciaLaboral and FechaInicio=@FechaInicio)
		BEGIN
			RAISERROR ('Ya Existe un Trabajo con esa Fecha',16,1)
				RETURN 
		END	
		
				select @OldJSON = a.JSON from [Reclutamiento].[tblExperienciaLaboral] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDCandidato = @IDCandidato;


		UPDATE [Reclutamiento].[tblExperienciaLaboral]
		   SET NombreEmpresa=UPPER(@NombreEmpresa) 
			,Cargo=UPPER(@Cargo)
			,FechaInicio=@FechaInicio 
			,FechaFin=case when @TrabajoActual=0 then @FechaFin else GETDATE() end	
			,Descripcion=UPPER(@Descripcion)
			,Logros=UPPER(@Logros)
			,Proyectos=UPPER(@Proyectos)			
			,Habilidades=UPPER(@Habilidades)
			,IDPais=CASE WHEN @IDPais			= 0	THEN NULL ELSE @IDPais			 END 
			,IDEstado=CASE WHEN @IDEstado		= 0	THEN NULL ELSE @IDEstado		 END 
			,IDMunicipio=CASE WHEN @IDMunicipio	= 0	THEN NULL ELSE @IDMunicipio		 END 
			,TrabajoActual=@TrabajoActual
			,IDTipoTrabajo=CASE WHEN @IDTipoTrabajo		= 0	THEN NULL ELSE @IDTipoTrabajo			   END 
			,IDModalidadTrabajo=CASE WHEN @IDModalidadTrabajo	= 0	THEN NULL ELSE @IDModalidadTrabajo END 	
		 WHERE [IDExperienciaLaboral] = @IDExperienciaLaboral 
            
		select @NewJSON = a.JSON from [Reclutamiento].[tblExperienciaLaboral] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDCandidato = @IDCandidato

		--EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Reclutamiento].[tblCandidatos]','[Reclutamiento].[spIUCandidato]','UPDATE',@NewJSON,''
		    -- exec [Reclutamiento].[spBuscarExperienciaLaboral] @IDCandidato = @IDCandidato,@IDUsuario = @IDUsuario
	END

END
GO
