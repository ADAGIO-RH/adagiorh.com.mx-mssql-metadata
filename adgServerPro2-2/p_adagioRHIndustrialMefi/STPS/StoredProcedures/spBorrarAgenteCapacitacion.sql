USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [STPS].[spBorrarAgenteCapacitacion](
	@IDAgenteCapacitacion int,
	@IDUsuario int
)
AS
BEGIN
	declare 
		@OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[STPS].[spBorrarAgenteCapacitacion]',
		@Tabla		varchar(max) = '[STPS].[tblAgentesCapacitacion]',
		@Accion		varchar(20)	= 'DELEte',
		@Mensaje	varchar(max),
		@InformacionExtra	varchar(max)
	;

	Exec STPS.spBuscarAgentesCapacitacion @IDAgenteCapacitacion = @IDAgenteCapacitacion
	
	BEGIN TRY
		select @OldJSON = a.JSON 
		from (
			SELECT A.IDAgenteCapacitacion,    
				ISNULL(UPPER(A.Codigo),'') as Codigo,    
				ISNULL(A.IDTipoAgente,0) as IDTipoAgente,    
				ISNULL(UPPER(TA.Descripcion),'') as TipoAgente,    
				ISNULL(UPPER(A.Nombre),'') as Nombre,    
				ISNULL(UPPER(A.Apellidos),'') as Apellidos,    
				ISNULL(UPPER(A.RFC),'') as RFC,    
				ISNULL(UPPER(A.RegistroSTPS),'') as RegistroSTPS,    
				ISNULL(UPPER(A.Contacto),'') as Contacto,    
				UPPER(COALESCE(A.RFC,'')+' - '+COALESCE(A.Nombre,'')+' '+COALESCE(A.Apellidos,'')) AS AgenteCapacitacionFull ,    
				ROW_NUMBER()OVER(ORDER BY A.IDAgenteCapacitacion) as ROWNUMBER    
			FROM STPS.tblAgentesCapacitacion A with (nolock)    
				inner join STPS.tblCatTiposAgentes TA with (nolock)   
					on TA.IDTipoAgente = A.IDTipoAgente    
			WHERE A.IDAgenteCapacitacion = @IDAgenteCapacitacion
		) b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a

		Delete STPS.tblAgentesCapacitacion
		where IDAgenteCapacitacion = @IDAgenteCapacitacion

		EXEC [Auditoria].[spIAuditoria]
			@IDUsuario		= @IDUsuario
			,@Tabla			= @Tabla
			,@Procedimiento	= @NombreSP
			,@Accion		= @Accion
			,@NewData		= @NewJSON
			,@OldData		= @OldJSON
			,@Mensaje		= @Mensaje
			,@InformacionExtra		= @InformacionExtra
	END TRY  
	BEGIN CATCH  
		EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
		return 0;
	END CATCH ;
END
GO
