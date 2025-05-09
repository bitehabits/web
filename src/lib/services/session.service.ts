import { AUTH_COOKIE_NAME } from '$lib/constants';
import { db } from '$lib/db/drizzle';
import { sessions } from '$lib/db/schemas';
import type { Cookies } from '@sveltejs/kit';
import { isPast } from 'date-fns';
import { eq } from 'drizzle-orm';

export const getValidSessionAndUser = async (sessionId: string) => {
	const session = await db.query.sessions.findFirst({
		where: (row, { eq }) => eq(row.id, sessionId),
		with: {
			user: true
		}
	});

	if (!session) {
		return null;
	}

	const isExpired = isPast(session.expiresAt);

	if (isExpired) {
		await db.delete(sessions).where(eq(sessions.id, session.id));

		return null;
	}

	const { user, ...sessionWithoutUser } = session;

	return {
		user,
		session: sessionWithoutUser
	};
};

export const deleteSession = async (sessionId: string) => {
	await db.delete(sessions).where(eq(sessions.id, sessionId));
};

export const clearSessionCookie = (cookies: Cookies) => {
	cookies.delete(AUTH_COOKIE_NAME, {
		path: '/'
	});
};
