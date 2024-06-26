USE [p_adagioRHMinutoAntes]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [RH].[spImportarTiposPrestacionesDetalle](
    @IDTipoPrestacion int
   ,@detalle [RH].[dtTiposPrestacionesDetalle] READONLY
   ,@IDUsuario int  
  ) as
begin

	DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max);

	--select @NewJSON = a.JSON from [RH].[tblCatTiposPrestacionesDetalle] b
	--	Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
	--	WHERE b.IDTipoPrestacion=@IDTipoPrestacion;

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatTiposPrestacionesDetalle]','[RH].[spImportarTiposPrestacionesDetalle]','DELETE - IMPORT','',''


    delete from [RH].[tblCatTiposPrestacionesDetalle]
    where IDTipoPrestacion=@IDTipoPrestacion;

    insert into [RH].[tblCatTiposPrestacionesDetalle](IDTipoPrestacion,Antiguedad,DiasAguinaldo,DiasVacaciones,PrimaVacacional)
    select @IDTipoPrestacion,Antiguedad,DiasAguinaldo,DiasVacaciones,PrimaVacacional
    from @detalle
    where Antiguedad is not null
end;
GO
