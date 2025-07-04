USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Actualizar conceptos chk
** Autor			: Jose Roman
** Email			: jose.roman@adagio.com.mx
** FechaCreacion	: 2018-01-01
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)		Autor					Comentario
-------------------		-------------------		------------------------------------------------------------

***************************************************************************************************/

CREATE PROCEDURE [Nomina].[spUConceptosChk]
(
	@IDConcepto int,
	@Columna varchar(50),
	@Value bit,
	@IDUsuario int
)
AS
BEGIN
	Declare @query Varchar(max)

	declare 
		@OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[Nomina].[spUConceptosChk]',
		@Tabla		varchar(max) = '[Nomina].[tblCatConceptos]',
		@Accion		varchar(20)	= 'UPDATE'

	select @OldJSON = a.JSON 
	from [Nomina].tblCatConceptos b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.Estatus,b.Impresion,b.bCantidadMonto,b.bCantidadDias,b.bCantidadVeces,b.bCantidadOtro1,b.bCantidadOtro2,b.LFT,b.Personalizada,b.ConDoblePago	For XML Raw)) ) a
	WHERE IDConcepto = @IDConcepto

	Set @query = 'UPDATE Nomina.tblCatConceptos set @Column = @Value where IDConcepto = @IDConcepto'
	
	set @query = REPLACE(REPLACE(REPLACE(@query,'@Column',@Columna),'@Value',cast(@Value as Varchar)),'@IDConcepto',cast(@IDConcepto as Varchar))

	Execute(@query);

	select @NewJSON = a.JSON 
	from [Nomina].tblCatConceptos b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.Estatus,b.Impresion,b.bCantidadMonto,b.bCantidadDias,b.bCantidadVeces,b.bCantidadOtro1,b.bCantidadOtro2,b.LFT,b.Personalizada,b.ConDoblePago For XML Raw)) ) a
	WHERE IDConcepto = @IDConcepto

	EXEC [Auditoria].[spIAuditoria]
		@IDUsuario		= @IDUsuario
		,@Tabla			= @Tabla
		,@Procedimiento	= @NombreSP
		,@Accion		= @Accion
		,@NewData		= @NewJSON
		,@OldData		= @OldJSON
END
GO
