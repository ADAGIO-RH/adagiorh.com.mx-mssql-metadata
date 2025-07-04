USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**************************************************************************************************** 
** Descripción		: Crear modificar catálogo de Parentescos
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2018-06-08
** Paremetros		: @IDParentesco INT
				 ,@Descripcion varchar(100)
				 ,@IDUsuario int             
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00		NombreCompleto		¿Qué cambió?
***************************************************************************************************/
CREATE proc [RH].[spIUParentesco](
    @IDParentesco INT
    ,@Descripcion varchar(100)
    ,@Traduccion varchar(max)
    ,@IDUsuario int
) as



 DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max);

    if (@IDParentesco = 0 or @IDParentesco is null)
    begin
	   INSERT INTO [RH].[TblCatParentescos](Descripcion	,Traduccion)
	   select @Descripcion , case when ISJSON(@Traduccion) > 0 then @Traduccion else null end

	   select @IDParentesco=@@identity;

	   	select @NewJSON = a.JSON from [RH].[TblCatParentescos] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDParentesco = @IDParentesco

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[TblCatParentescos]','[RH].[spIUParentesco]','INSERT',@NewJSON,''
		

    end else
    begin
	
	   	select @OldJSON = a.JSON from [RH].[TblCatParentescos] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDParentesco = @IDParentesco

	   update [RH].[TblCatParentescos]
		set Descripcion = @Descripcion
        ,Traduccion =case when ISJSON(@Traduccion) > 0 then @Traduccion else null end
	   where IDParentesco = @IDParentesco  

	   select @NewJSON = a.JSON from [RH].[TblCatParentescos] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDParentesco = @IDParentesco

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[TblCatParentescos]','[RH].[spIUParentesco]','UPDATE',@NewJSON,@OldJSON
		
    end;

    exec [RH].[spBuscarCatParentesco] @IDParentesco
GO
