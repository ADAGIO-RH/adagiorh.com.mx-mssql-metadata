USE [p_adagioRHNomade]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblLectoresEmpleados20220315](
	[IDLectorEmpleado] [int] IDENTITY(1,1) NOT NULL,
	[IDLector] [int] NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[Fecha] [datetime] NULL
) ON [PRIMARY]
GO
