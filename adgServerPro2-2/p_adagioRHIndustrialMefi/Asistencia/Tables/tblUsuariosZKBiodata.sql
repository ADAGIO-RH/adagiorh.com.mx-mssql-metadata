USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Asistencia].[tblUsuariosZKBiodata](
	[IDUsuariosZKBiodata] [int] IDENTITY(1,1) NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[EnrollNumber] [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[TemplateNumber] [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Index] [int] NOT NULL,
	[Valid] [bit] NOT NULL,
	[Duress] [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Type] [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[MajorVer] [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[MinorVer] [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Format] [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Template] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
 CONSTRAINT [PK_AsistenciaTblUsuariosZKUserBiodata_IDUsuariosZKUserBiodata] PRIMARY KEY CLUSTERED 
(
	[IDUsuariosZKBiodata] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Asistencia].[tblUsuariosZKBiodata]  WITH CHECK ADD  CONSTRAINT [FK_RHtblEmpleados_AsistenciaTblUsuariosZKUserBiodata_IDEmpleado] FOREIGN KEY([IDEmpleado])
REFERENCES [RH].[tblEmpleados] ([IDEmpleado])
GO
ALTER TABLE [Asistencia].[tblUsuariosZKBiodata] CHECK CONSTRAINT [FK_RHtblEmpleados_AsistenciaTblUsuariosZKUserBiodata_IDEmpleado]
GO
