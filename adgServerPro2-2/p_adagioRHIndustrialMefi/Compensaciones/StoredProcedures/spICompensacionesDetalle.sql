USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Compensaciones].[spICompensacionesDetalle](
	@IDCompensacion int 
	,@IDEmpleado int
	,@IDUsuario int 
)
AS
BEGIN
		DECLARE 
		@OldJSON Varchar(Max),
		@NewJSON Varchar(Max),
		@IDCompensacionesDetalle int
	;


		INSERT INTO Compensaciones.TblCompensacionesDetalle(
			 IDCompensacion
			,IDEmpleado
			,IndiceSalarial
			,IndiceSalarialNuevo
			,Salario
			,SalarioNuevo
			,SalarioDiario
			,SalarioDiarioNuevo
			,Compensacion
		)
		VALUES(
			 @IDCompensacion
			 ,@IDEmpleado
			 ,0.00
			 ,0.00
			 ,0.00
			 ,0.00
			 ,0.00
			 ,0.00
			 ,0.00
		)

		set @IDCompensacionesDetalle = @@identity  

		select @NewJSON = a.JSON from Compensaciones.TblCompensacionesDetalle b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDCompensacionesDetalle = @IDCompensacionesDetalle

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Compensaciones].[TblCompensacionesDetalle]','[Compensaciones].[spICompensacionesDetalle]','INSERT',@NewJSON,''
	
END
GO
