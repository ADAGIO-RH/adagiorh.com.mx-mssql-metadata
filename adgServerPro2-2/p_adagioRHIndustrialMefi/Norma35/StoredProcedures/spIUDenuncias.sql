USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Norma35].[spIUDenuncias]
(
	 @IDDenuncia INT = 0

	,@IDTipoDenuncia INT  =null 
    ,@EsAnonima  BIT  =null 
    ,@IDEmpleadoDenunciante INT =null 
    ,@IDTipoDenunciado INT =null 
    ,@Denunciados VARCHAR(MAX) =null 
    ,@DescripcionHechos VARCHAR(MAX) =null 
    ,@DescripcionHechosHTML VARCHAR(MAX) =null 

    ,@IDEstatusDenuncia INT = null 
    ,@Justificacion VARCHAR(MAX) = null
	,@FechaEvento date = null
	,@IDUsuario int    
)
AS
BEGIN

    
	declare @IDCliente int ;
    declare @IDEmpleado int;
	DECLARE @OldJSON VARCHAR(MAX),
		    @NewJSON VARCHAR(MAX);

    select @IDCliente=s.IDCliente from rh.tblEmpleadosMaster s where s.IDEmpleado=@IDEmpleadoDenunciante;

    if(@EsAnonima=1)
        BEGIN
          set @IDEmpleado=0
        end
    else
        BEGIN 
            set @IDEmpleado=@IDEmpleadoDenunciante
        end

	IF(ISNULL(@IDDenuncia,0) = 0)
	BEGIN
		INSERT INTO [Norma35].[tblDenuncias]
				   ([IDTipoDenuncia]
				   ,[EsAnonima]
				   ,[IDEmpleadoDenunciante]
				   ,[IDTipoDenunciado]
				   ,[Denunciados]
				   ,[DescripcionHechos]
				   ,[DescripcionHechosHTML]
				   ,[IDEstatusDenuncia]
				   ,[Justificacion]
				   ,[FechaEvento]
				   ,[FechaRegistro]
                   ,[IDCliente])
			 VALUES
				   (
					 @IDTipoDenuncia 
					,@EsAnonima   
					,@IDEmpleado 
					,@IDTipoDenunciado 
					,@Denunciados 
					,@DescripcionHechos 
					,@DescripcionHechosHTML 
					,@IDEstatusDenuncia 
					,@Justificacion 
					,@FechaEvento
					,GETDATE()
                    ,@IDCliente)

		SET @IDDenuncia = @@IDENTITY

		select @NewJSON = a.JSON from [Norma35].[tblDenuncias] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDDenuncia = @IDDenuncia

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Norma35].[tblDenuncias]','[Norma35].[spIUDenuncias]','INSERT',@NewJSON,''

        EXEC [Scheduler].[spSchedulerNotificacionEspecial_NuevoDenuncia]  
        @IDDenuncia = @IDDenuncia

	END
	ELSE
	BEGIN
		select @OldJSON = a.JSON from [Norma35].[tblDenuncias] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDDenuncia = @IDDenuncia

    
		UPDATE [Norma35].[tblDenuncias]
		   SET [IDTipoDenuncia] = isnull(@IDTipoDenuncia,[IDTipoDenuncia])
			  ,[EsAnonima] = isnull(@EsAnonima,[EsAnonima])
			  ,[IDEmpleadoDenunciante] =isnull(@IDEmpleado,[IDEmpleadoDenunciante])
			  ,[IDTipoDenunciado] = isnull(@IDTipoDenunciado,[IDTipoDenunciado]) 
			  ,[Denunciados] = isnull(@Denunciados,[Denunciados])
			  ,[DescripcionHechos] =isnull(@DescripcionHechos,[DescripcionHechos])  
			  ,[DescripcionHechosHTML] =isnull(@DescripcionHechosHTML,[DescripcionHechosHTML])
			  ,[IDEstatusDenuncia] =isnull(@IDEstatusDenuncia,[IDEstatusDenuncia]) 
			  ,[Justificacion] = isnull(@Justificacion,[Justificacion]) 
		 WHERE IDDenuncia = @IDDenuncia

		select @NewJSON = a.JSON from [Norma35].[tblDenuncias] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDDenuncia = @IDDenuncia

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Norma35].[tblDenuncias]','[Norma35].[spIUDenuncias]','UPDATE',@NewJSON,@OldJSON		
	END

	EXECUTE [Norma35].[spBuscarDenunciaByID]  @IDDenuncia ,@IDUsuario
END;
GO
