USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spIUUbicacionesEmpleados]
( 
    @IDUbicacionEmpleado int = 0
	,@IDEmpleado int = 0
	,@IDUbicacion int = 0
    ,@IDUsuario int
)

AS
BEGIN
    DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max); 

	IF(isnull(@IDUbicacionEmpleado,0) = 0)
	BEGIN
		if not EXISTS(select top 1 1 from [RH].[tblUbicacionesEmpleados]where IDEmpleado= @IDEmpleado)
		BEGIN
			insert into RH.tblUbicacionesEmpleados(IDEmpleado,IDUbicacion)
			values(@IDEmpleado,@IDUbicacion)

			set @IDUbicacionEmpleado = @@IDENTITY
			select @NewJSON = a.JSON from [RH].[tblUbicacionesEmpleados] b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
			WHERE b.IDUbicacionEmpleado = @IDUbicacionEmpleado

		END		
	   
	END
	ELSE
	BEGIN

		select @OldJSON = a.JSON from [RH].[tblUbicacionesEmpleados] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDUbicacionEmpleado = @IDUbicacionEmpleado

		UPDATE [RH].[tblUbicacionesEmpleados]
			set IDEmpleado = @IDEmpleado,
				IDUbicacion = @IDUbicacion				
		WHERE IDUbicacionEmpleado = @IDUbicacionEmpleado

		select @NewJSON = a.JSON from [RH].[tblUbicacionesEmpleados]  b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDUbicacionEmpleado = @IDUbicacionEmpleado

	   
	END
END;
GO
