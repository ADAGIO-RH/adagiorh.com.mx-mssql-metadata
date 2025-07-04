USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   proc [Comunicacion].[spIUNotificacionBirthday](
	 @IDNotificacionBirthday int = 0
	,@Nombre varchar(255)
	,@Asunto varchar(max)
	,@Body varchar(max)
	,@Actual bit
	,@IDIdioma varchar(10)
	,@IDUsuario int
) as

	--Comprueba si el valor de la variable @Actual es igual a 1
	--y si existe al menos una fila en la tabla Comunicacion.tblNotificacionBirthday
	--donde el valor de la columna IDIdioma sea igual al valor de la variable @IDIdioma
	--y la columna Actual sea igual al valor de la variable @Actual
	if
		( isnull(@Actual, 0) = 1
			and 
		exists(select top 1 1
			from Comunicacion.tblNotificacionBirthday
			where IDIdioma = @IDIdioma and Actual = @Actual)
		)
	begin
		-- Si se cumplen ambas condiciones, se ejecuta una instrucción UPDATE
		-- para actualizar todas las filas en la tabla Comunicacion.tblNotificacionBirthday
		-- donde el valor de la columla IDIdioma sea igual al valor de la variable @IDIdioma
		-- y el valor de la columna Actual sea igual al valor de la variable @Actual
		-- La actualización consiste en cambiar el valor de la columna Actual a 0 en todas las filas afectadas
		update Comunicacion.tblNotificacionBirthday
			set 
				Actual = 0
		where IDIdioma = @IDIdioma and Actual = @Actual
	end

	if (isnull(@IDNotificacionBirthday, 0) = 0)
	begin
		insert Comunicacion.tblNotificacionBirthday(Nombre, Asunto, Body, Actual, IDIdioma, IDUsuario)
		select UPPER(@Nombre), UPPER(@Asunto),  @Body, @Actual, @IDIdioma, @IDUsuario

		set @IDNotificacionBirthday = SCOPE_IDENTITY()
	end else
	begin
		update Comunicacion.tblNotificacionBirthday
			set
				Nombre = UPPER(@Nombre),
				Asunto = UPPER(@Asunto),
				Body = @Body,
				Actual = @Actual
				--IDUsuario = @IDUsuario
		where IDNotificacionBirthday = @IDNotificacionBirthday
	end
--GO
GO
