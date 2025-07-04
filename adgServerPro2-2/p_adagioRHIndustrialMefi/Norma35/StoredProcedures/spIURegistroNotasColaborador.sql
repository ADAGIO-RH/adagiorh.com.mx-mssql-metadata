USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [Norma35].[spIURegistroNotasColaborador]
	-- Add the parameters for the stored procedure here
    @IDRegistroNotasColaborador int ,
	@IDEmpleado int , 
    @Titulo varchar(50),
    @Notas varchar(max),
    @IDUsuario int 
AS
BEGIN
	
    
    DECLARE @OldJson  varchar(max)
            ,@NewJson varchar(max);

    if(isnull(@IDRegistroNotasColaborador,0)=0)
        begin 
            
            INSERT INTO Norma35.tblRegistroNotasColaborador (IDEmpleado, Titulo,Notas, FechaRegistro,IDUsuarioRegistro)
            values( @IDEmpleado, @Titulo,@Notas,getdate(),@IDUsuario)


            SET @IDRegistroNotasColaborador = @@IDENTITY

            select @NewJSON = a.JSON from [Norma35].[tblDenuncias] b
            Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
            WHERE b.IDDenuncia = @IDRegistroNotasColaborador

            EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Norma35].[tblRegistroNotasColaborador]','[Norma35].[spIURegistroNotasColaborador]','INSERT',@NewJSON,''

            select @IDRegistroNotasColaborador [id];
        end 
    ELSE 
        BEGIN 
            select @OldJSON = a.JSON from [Norma35].[tblDenuncias] b
            Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
            WHERE b.IDDenuncia = @IDRegistroNotasColaborador
            
            UPDATE [Norma35].tblRegistroNotasColaborador
            SET
                Notas = @Notas ,
                Titulo  =@Titulo                                 
            WHERE  IDRegistroNotasColaborador = @IDRegistroNotasColaborador

            
            select @NewJSON = a.JSON from [Norma35].[tblDenuncias] b
            Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
            WHERE b.IDDenuncia = @IDRegistroNotasColaborador


            EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Norma35].[tblRegistroNotasColaborador]','[Norma35].[spIURegistroNotasColaborador]','UPDATE',@NewJSON,@OldJSON		
            
        END
END;
GO
