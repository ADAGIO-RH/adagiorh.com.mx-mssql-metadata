USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spUIJornadaEmpleado]
(
	@IDJornadaEmpleado int = 0
	,@IDEmpleado int
	,@IDJornada int
	,@FechaIni date
	,@FechaFin date
	,@IDUsuario int
)
AS
BEGIN

  DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max)

	IF(@IDJornadaEmpleado = 0 or @IDJornadaEmpleado is null)
	BEGIN
		DECLARE @LastHistoryID int,
				@LastDate date
		IF EXISTS(Select * from RH.tblJornadaEmpleado where IDEmpleado = @IDEmpleado)
		BEGIN
				SELECT @LastHistoryID = IDJornadaEmpleado,
					   @LastDate = MAX(FechaIni)
				FROM RH.tblJornadaEmpleado
				WHERE IDEmpleado = @IDEmpleado
				GROUP BY IDJornadaEmpleado

				UPDATE RH.tblJornadaEmpleado
					SET FechaFin = DATEADD(DAY,-1,@FechaIni)
				WHERE IDEmpleado = @IDEmpleado
					and IDJornadaEmpleado = @LastHistoryID

				INSERT INTO RH.tblJornadaEmpleado
							(
							IDEmpleado
							,IDJornada
							,FechaIni
							,FechaFin
							)
				VALUES(
						@IDEmpleado
						,@IDJornada
						,@FechaIni
						,@FechaFin
						)
			set @IDJornadaEmpleado = @@IDENTITY

			select @NewJSON = a.JSON from [RH].[tblJornadaEmpleado] b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
			WHERE b.IDJornadaEmpleado = @IDJornadaEmpleado

			EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblJornadaEmpleado]','[RH].[spUIJornadaEmpleado]','INSERT',@NewJSON,''

		END
		ELSE
		BEGIN
				INSERT INTO RH.tblJornadaEmpleado
							(
							IDEmpleado
							,IDJornada
							,FechaIni
							,FechaFin
							)
				VALUES(
						@IDEmpleado
						,@IDJornada
						,@FechaIni
						,@FechaFin
						)

			set @IDJornadaEmpleado = @@IDENTITY

			select @NewJSON = a.JSON from [RH].[tblJornadaEmpleado] b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
			WHERE b.IDJornadaEmpleado = @IDJornadaEmpleado

			EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblJornadaEmpleado]','[RH].[spUIJornadaEmpleado]','INSERT',@NewJSON,''
		END
	END
	ELSE
	BEGIN
		select @OldJSON = a.JSON from [RH].[tblJornadaEmpleado] b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
			WHERE b.IDJornadaEmpleado = @IDJornadaEmpleado

		UPDATE RH.tblJornadaEmpleado
					SET FechaFin = @FechaFin,
						FechaIni = @FechaIni,
						IDJornada = @IDJornada
				WHERE IDEmpleado = @IDEmpleado
					and IDJornadaEmpleado = @IDJornadaEmpleado
		select @NewJSON = a.JSON from [RH].[tblJornadaEmpleado] b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
			WHERE b.IDJornadaEmpleado = @IDJornadaEmpleado

			EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblJornadaEmpleado]','[RH].[spUIJornadaEmpleado]','UPDATE',@NewJSON,@OldJSON
	END

	EXEC RH.spMapSincronizarEmpleadosMaster @IDEmpleado = @IDEmpleado
	
END
GO
