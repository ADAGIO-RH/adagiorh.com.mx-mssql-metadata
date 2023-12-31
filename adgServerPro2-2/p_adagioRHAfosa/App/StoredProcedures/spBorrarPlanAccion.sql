USE [p_adagioRHAfosa]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**************************************************************************************************** 
** Descripción		: Borrar plan de accion
** Autor			: Javier Peña
** Email			: jpena@adagio.com.mx
** FechaCreacion	: 2023-02-20
** Paremetros		:   

****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------

***************************************************************************************************/
CREATE proc [App].[spBorrarPlanAccion](
	@IDPlanAccion int = 0
   ,@IDReferencia int = 0
   ,@IDTipoPlanAccion int =0
   ,@IDUsuario int
   
) as

	declare 

        @OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[App].[spBorrarPlanAccion]',
		@Tabla		varchar(max) = '[App].[tblPlanAccion]',
		@Accion		varchar(20)	= 'DELETE',
		@Mensaje	varchar(max),
		@InformacionExtra	varchar(max),
        @ID_TIPO_COMENTARIO_PLAN_ACCION int = 5;

	;

	if object_id('tempdb..#tempResponse') is not null drop table #tempResponse;
			
    BEGIN TRY  
	IF(ISNULL(@IDPlanAccion,0) <> 0)
    BEGIN
        	SELECT @OldJSON = a.JSON 
                FROM (
                    SELECT PAO.*
                    FROM [App].[tblPlanAccion] PAO                        
                          WHERE PAO.IDPlanAccion=@IDPlanAccion
                ) b
			CROSS APPLY (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
                    
            
            DELETE
            FROM APP.tblComentarios  
            WHERE IDReferencia=@IDPlanAccion 
            AND IDTipoComentario=@ID_TIPO_COMENTARIO_PLAN_ACCION
            
            DELETE FROM [App].[tblPlanAccion] 
            WHERE IDPlanAccion=@IDPlanAccion
    END
    ELSE IF(ISNULL(@IDPlanAccion,0) = 0 AND ISNULL(@IDReferencia,0)<> 0 AND ISNULL(@IDTipoPlanAccion,0)<> 0 )
    BEGIN
        SELECT @OldJSON = a.JSON 
                FROM (
                    SELECT PAO.*
                    FROM [App].[tblPlanAccion] PAO                        
                          WHERE PAO.IDReferencia=@IDReferencia and PAO.IDTipoPlanAccion=@IDTipoPlanAccion
                ) b
			CROSS APPLY (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a


            DELETE
            FROM APP.tblComentarios  
            WHERE  IDTipoComentario=@ID_TIPO_COMENTARIO_PLAN_ACCION
            AND IDReferencia IN(
                SELECT IDPlanAccion
                    FROM [App].[tblPlanAccion]               
                WHERE IDReferencia=@IDReferencia and IDTipoPlanAccion=@IDTipoPlanAccion
            )

            DELETE FROM [App].[tblPlanAccion] 
                WHERE IDReferencia=@IDReferencia and IDTipoPlanAccion=@IDTipoPlanAccion
    END
    

			EXEC [Auditoria].[spIAuditoria]
				@IDUsuario		= @IDUsuario
				,@Tabla			= @Tabla
				,@Procedimiento	= @NombreSP
				,@Accion		= @Accion
				,@NewData		= @NewJSON
				,@OldData		= @OldJSON
				,@Mensaje		= @Mensaje
				,@InformacionExtra		= @InformacionExtra

			SELECT 'Se ha eliminado correctamente' as Mensaje
		    RETURN;

		
    END TRY  
    BEGIN CATCH  
	   EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
	   return 0;
    END CATCH ;
GO
