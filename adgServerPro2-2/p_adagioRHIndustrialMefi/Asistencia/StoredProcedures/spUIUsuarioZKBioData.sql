USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: <Procedure para guardar y actualizar los rostros sacados de checadores ZK>
** Autor			: <Denzel Ovando>
** Email			: <denzel.ovando@adagio.com.mx>
** FechaCreacion	: <2021-11-09>
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				    Comentario
------------------- -------------------     ------------------------------------------------------------
0000-00-00		    NombreCompleto		    ¿Qué cambió?
***************************************************************************************************/

CREATE PROCEDURE [Asistencia].[spUIUsuarioZKBioData]
(
	 @IDUsuariosZKBiodata int = 0
	,@IDEmpleado int 
    ,@EnrollNumber varchar(25)
    ,@TemplateNumber varchar(25)
    ,@Index int
    ,@Valid bit
    ,@Duress varchar(25)
    ,@Type varchar(25)
    ,@MajorVer varchar(25)
    ,@MinorVer varchar(25)
    ,@Format varchar(25)
    ,@Template nvarchar(max)
	,@IDUsuario int = 1
)
AS
BEGIN
 
  DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max); 

	IF NOT EXISTS (SELECT top 1 1 FROM [Asistencia].[tblUsuariosZKBiodata] 
		WHERE [IDEmpleado] = @IDEmpleado 
		  and [TemplateNumber] = @TemplateNumber
		  and [Index] = @Index)
	BEGIN

	INSERT INTO [Asistencia].[tblUsuariosZKBiodata]
           ([IDEmpleado]
           ,[EnrollNumber]
           ,[TemplateNumber]
           ,[Index]
           ,[Valid]
           ,[Duress]
           ,[Type]
           ,[MajorVer]
           ,[MinorVer]
           ,[Format]
           ,[Template])
     VALUES
           (@IDEmpleado 
			,@EnrollNumber 
			,@TemplateNumber
			,@Index 
			,@Valid 
			,@Duress 
			,@Type 
			,@MajorVer 
			,@MinorVer 
			,@Format 
			,@Template)


		SET @IDUsuariosZKBiodata = @@IDENTITY

		select @NewJSON = a.JSON from [Asistencia].[tblUsuariosZKBiodata] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDUsuariosZKBiodata = @IDUsuariosZKBiodata

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Asistencia].[tblUsuariosZKBiodata]','[Asistencia].[spUIUsuarioZKBioData]','INSERT',@NewJSON,''

	END
	ELSE
	BEGIN

		select @OldJSON = a.JSON from [Asistencia].[tblUsuariosZKBiodata] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE  b.IDUsuariosZKBiodata = @IDUsuariosZKBiodata

		UPDATE [Asistencia].[tblUsuariosZKBiodata]
			SET [IDEmpleado] = @IDEmpleado
				,[EnrollNumber] = @EnrollNumber
				,[TemplateNumber] = @TemplateNumber
				,[Index] = @Index
				,[Valid] = @Valid
				,[Duress] = @Duress
				,[Type] = @Type
				,[MajorVer] = @MajorVer
				,[MinorVer] = @MinorVer
				,[Format] = @Format
				,[Template] = @Template
			WHERE [IDEmpleado] = @IDEmpleado 
				and [TemplateNumber] = @TemplateNumber
				and [Index] = @Index


		select @NewJSON = a.JSON from [Asistencia].[tblUsuariosZKBiodata] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE  b.IDUsuariosZKBiodata = @IDUsuariosZKBiodata

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Asistencia].[tblUsuariosZKBiodata]','[Asistencia].[spUIUsuarioZKBioData]','UPDATE',@NewJSON,@OldJSON
	END
	
	exec [Asistencia].[spBuscarUsuariosZKBioData]
		@IDEmpleado = @IDEmpleado
	
END
GO
